import credits.aleo;

// The 'artgo_aigc_v0_1.aleo' program.
program artgo_aigc_v0_1.aleo{

//     const THIS_ADDRESS: address = self.caller;
    const INITIALIZER: address = aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88;

    // order status
    const ORDER_STATUS_TRADING: u8 = 1u8;
    const ORDER_STATUS_CANCELLED: u8 = 2u8;
    const ORDER_STATUS_FINISHED: u8 = 3u8;
    // order type
    const ORDER_TYPE_NORMAL: u8 = 1u8;
    const ORDER_TYPE_AUCTION: u8 = 2u8;

    // bid type
    const BID_TYPE_BID: u8 = 1u8;
    const BID_TYPE_CANCEL: u8 = 2u8;

//     struct Field2 {
//         first: field,
//         second: field,
//     }

    struct NftHash {
        minter: address,
        prompt: [u128;3],
        nonce: u128,
    }

    struct NftInfo {
        holder: address,
        minter: address,
        hash: field,
        uri: [u128;3],
    }

    struct Order {
        holder: address,
        nft_id: u128,
        order_type: u8,
        amount: u64,
        status: u8,
        deadline: u32,
    }

    struct Bid {
        bidder: address,    // bidder address
        nft_id: u128,
        amount: u64,
    }

    record BidRecord {
        bid_type: u8,           //1-bid, 2-cancel
        owner: address,     
        bidder: address,
        nft_id: u128,
        amount: u64,
    }

    record Nft {
        owner: address,
        minter: address,
        prompt: [u128;3],
        nonce: u128,
        uri: [u128;3],
    }

    //nft id --> nft info
    mapping nfts: u128 => NftInfo;
    //true --> next nft id
    mapping next_nft_id: bool => u128;
    //nft id --> Order
    mapping orders: u128 => Order;
    //nft id --> bid
    mapping bids: u128 => Bid;
    //true -> Setting
    mapping settings: bool => Setting;

    struct Setting {
        admin: address,
        operator: address,
        fee: u64,
    }

    async transition init(
        public admin: address,
        public operator: address,
        public fee: u64
    ) -> Future {
        assert_eq(self.caller, INITIALIZER);

        return finalize_init(
            admin,
            operator,
            fee,
        );
    }

    async function finalize_init(
        admin: address,
        operator: address,
        fee: u64
    ) {
        assert_eq(settings.contains(true), false);

        settings.set(
            true,
            Setting {
                admin: admin,
                operator: operator,
                fee: fee,
            }
        );

        next_nft_id.set(
            true,
            1u128
        );
    }

    // mint aigc nft
    async transition mint_nft(
        private prompt: [u128;3],
        public uri: [u128;3],
        public nonce: u128
    ) -> (Nft, Future) {
        let hash: field = BHP256::hash_to_field(
            NftHash {
                minter: self.caller,
                prompt: prompt,
                nonce: nonce,
            },
        );

        let nft: Nft = Nft {
            owner: self.caller,
            minter: self.caller,
            prompt: prompt,
            nonce: nonce,
            uri: uri,
        };

        let f: Future = finalize_mint_nft(
                self.caller,
                hash,
                uri,
        );

        return (nft, f);
    }

    async function finalize_mint_nft(
        holder: address,
        hash: field,
        uri: [u128;3],
    ) {
        let nft_id: u128 = next_nft_id.get(true);

        next_nft_id.set(
            true,
            nft_id + 1u128,
        );

        nfts.set(
            nft_id,
            NftInfo{
                holder: holder,
                minter: holder,
                hash: hash,
                uri: uri,
            },
        );
    }

    async transition transfer_private_nft(
        nft_id: u128,
        nft: Nft,
        receiver: address
    ) -> (Nft, Future) {
        let hash: field = BHP256::hash_to_field(
            NftHash {
                minter: nft.minter,
                prompt: nft.prompt,
                nonce: nft.nonce,
            },
        );

        let transferred: Nft = Nft {
            owner: receiver,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        let f: Future = finalize_transfer_private_nft(
            nft_id,
            hash,
            nft.uri,
            receiver,
        );

        return (transferred, f);
    }

    async function finalize_transfer_private_nft(
        nft_id: u128,
        hash: field,
        uri: [u128;3],
        receiver: address,
    ) {
        let nft: NftInfo = nfts.get(nft_id);
        assert_eq(nft.hash, hash);
        assert_eq(nft.uri, uri);

        nfts.set(
            nft_id,
            NftInfo {
                holder: receiver,
                minter: nft.minter,
                hash: nft.hash,
                uri: nft.uri,
            },
        );
    }

    async transition place_order(
        public nft_id: u128,
        private nft: Nft,
        public order_type: u8,
        public amount: u64,
        public deadline: u32,
        public operator_in: address
    ) -> (Nft, Future) {
        // only support buy / sell atm
        assert_eq(order_type, ORDER_TYPE_NORMAL);

        let hash: field = BHP256::hash_to_field(
            NftHash {
                minter: nft.minter,
                prompt: nft.prompt,
                nonce: nft.nonce,
            }
        );

        // find order based on hash offchain
        let nft_transfer : Nft = Nft {
            owner: operator_in,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        let f: Future = finalize_place_order(
            operator_in,
            nft_id,
            hash,
            nft.uri,
            self.caller,
            order_type,
            amount,
            deadline,
        );

        return (nft_transfer, f);
    }

    async function finalize_place_order(
        operator_in: address,
        nft_id: u128,
        hash: field,
        uri: [u128;3],
        caller: address,
        order_type: u8,
        amount: u64,
        deadline: u32,
    ) {
        assert(deadline > block.height);

        let setting: Setting = settings.get(true);
        assert_eq(operator_in, setting.operator);
        assert(amount >= setting.fee);

        let nft: NftInfo = Mapping::get(nfts, nft_id);
        assert_eq(nft.hash, hash);
        assert_eq(nft.uri, uri);

        // update order information
        assert_eq(orders.contains(nft_id), false);
        orders.set(
            nft_id,
            Order {
                holder: caller,
                nft_id: nft_id,
                amount: amount,
                order_type: order_type,
                status: ORDER_STATUS_TRADING,
                deadline: deadline,
            },
        );
    }

    async transition update_order(
        public nft_id: u128,
        public new_amount: u64,
    ) -> Future {
        return finalize_update_order(
            self.caller,
            nft_id,
            new_amount
        );
    }

    async function finalize_update_order(
        owner: address,
        nft_id: u128,
        amount_new: u64,
    ) {
        let setting: Setting = settings.get(true);
        assert(amount_new >= setting.fee);

        let order: Order = orders.get(nft_id);
        assert_eq(order.status, ORDER_STATUS_TRADING);
        assert_eq(owner, order.holder);

        orders.set(
            nft_id,
            Order {
                holder: order.holder,
                nft_id: order.nft_id,
                amount: amount_new,
                order_type: order.order_type,
                status: order.status,
                deadline: order.deadline,
            },
        );
    }

    async transition cancel_order(
        private credit: credits.aleo/credits,
        public fee: u64,
        public nft_id: u128,
        public operator_in: address,
    ) -> (credits.aleo/credits, BidRecord, Future) {
        let bid_record: BidRecord = BidRecord {
            owner: operator_in,
            bid_type: BID_TYPE_CANCEL,
            bidder: self.caller,
            nft_id: nft_id,
            amount: 0u64,
        };

        // lock fee in this program
        let (change, f_credits_transfer_private_to_public): (credits.aleo/credits, Future) =
            credits.aleo/transfer_private_to_public(credit, self.address, fee);

        let f: Future = finalize_cancel_order(
            self.caller,
            nft_id,
            fee,
            operator_in,
            f_credits_transfer_private_to_public,
        );

        return (change, bid_record, f);
    }

    async function finalize_cancel_order(
        owner: address,
        nft_id: u128,
        fee: u64,
        operator_in: address,
        f_credits_transfer_private_to_public: Future,
    ) {
        f_credits_transfer_private_to_public.await();
        let setting: Setting = settings.get(true);
        assert_eq(fee, setting.fee);
        assert_eq(operator_in, setting.operator);

        let order: Order = orders.get(nft_id);
        assert_eq(order.status, ORDER_STATUS_TRADING);
        assert_eq(owner, order.holder);

        orders.set(
            nft_id,
            Order {
                holder: order.holder,
                nft_id: order.nft_id,
                amount: order.amount,
                order_type: order.order_type,
                status: ORDER_STATUS_CANCELLED,
                deadline: order.deadline,
            },
        );
    }

    // handle cancel order, delete states
    async transition handle_cancel_order(
        public nft_id: u128,
        private nft: Nft,
        public receiver: address,
    ) -> (Nft, Future) {
        let nft_transfer : Nft = Nft {
            owner: receiver,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        let hash: field = BHP256::hash_to_field(
            NftHash {
                minter: nft.minter,
                prompt: nft.prompt,
                nonce: nft.nonce,
            },
        );

        let f: Future = finalize_handle_cancel_order(
            nft_id,
            hash,
            nft.uri,
            receiver,
            self.caller,
        );

        return (nft_transfer, f);
    }

    async function finalize_handle_cancel_order(
        nft_id: u128,
        hash: field,
        uri: [u128;3],
        receiver: address,
        caller: address,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.operator);

        // verify nft
        let nft: NftInfo = nfts.get(nft_id);
        assert_eq(nft.hash, hash);
        assert_eq(nft.uri, uri);

        // verify order
        let order: Order = orders.get(nft_id);
        assert_eq(order.status, ORDER_STATUS_CANCELLED);
        assert_eq(receiver, order.holder);

        // clear mappings
        bids.remove(nft_id);
        orders.remove(nft_id);
    }

    async transition bid_order(
        private credit: credits.aleo/credits,
        public nft_id: u128,
        public amount: u64,
        public operator_in: address,
    ) -> (BidRecord, credits.aleo/credits, Future) {
        let bid_record: BidRecord = BidRecord {
            owner: operator_in,
            bid_type: BID_TYPE_BID,
            bidder: self.caller,
            nft_id: nft_id,
            amount: amount,
        };

        // lock credits in this program
        let (change, f_credits_transfer_private_to_public): (credits.aleo/credits, Future) =
            credits.aleo/transfer_private_to_public(credit, self.address, amount);

        let f: Future = finalize_bid_order(
            self.caller,
            nft_id,
            amount,
            operator_in,
            f_credits_transfer_private_to_public,
        );

        return (bid_record, change, f);
    }

    async function finalize_bid_order(
        caller: address,
        nft_id: u128,
        amount: u64,
        operator_in: address,
        f_credits_transfer_private_to_public: Future,
    ) {
        f_credits_transfer_private_to_public.await();
        let setting: Setting = settings.get(true);
        assert_eq(operator_in, setting.operator);

        // add bid
        bids.set(
            nft_id,
            Bid {
                bidder: caller,
                nft_id: nft_id,
                amount : amount,
            },
        );

        // verify order
        let order: Order = orders.get(nft_id);
        assert_eq(order.status, ORDER_STATUS_TRADING);
        assert(amount >= order.amount);
        // deadline check
        assert(block.height < order.deadline);

        // update order
        orders.set(
            nft_id,
            Order {
                holder: order.holder,
                nft_id: order.nft_id,
                amount: order.amount,
                order_type: order.order_type,
                status: ORDER_STATUS_FINISHED,
                deadline: order.deadline,
            },
        );
    }

    // ONLY OPERATOR
    async transition finish_order(
        public nft_id: u128,
        private nft: Nft,
        public holder: address,
        public fee: u64,
        public winner: address,
        public winner_amount: u64,
    ) -> (Nft, Future){
        let hash: field = BHP256::hash_to_field(
            NftHash {
                minter: nft.minter,
                prompt: nft.prompt,
                nonce: nft.nonce,
            },
        );

        let nft_transfer : Nft = Nft {
            owner: winner,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        // transfer remaining amount
        let f_credits_transfer_public: Future =
            credits.aleo/transfer_public(holder, winner_amount - fee);

        let f: Future = finalize_finish_order(
            nft_id,
            holder,
            hash,
            nft.uri,
            winner,
            winner_amount,
            fee,
            self.caller,
            f_credits_transfer_public,
        );

        return (nft_transfer, f);
    }

    async function finalize_finish_order(
        nft_id: u128,
        holder: address,
        hash: field,
        uri: [u128;3],
        winner: address,
        winner_amount: u64,
        fee: u64,
        caller: address,
        f_credits_transfer_public: Future,
    ) {
        f_credits_transfer_public.await();
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.operator);
        assert_eq(fee, setting.fee);

        // verify order status
        assert_eq(orders.get(nft_id).status, ORDER_STATUS_FINISHED);

        let nft: NftInfo = nfts.get(nft_id);
        assert_eq(nft.hash, hash);
        assert_eq(nft.uri, uri);
        assert_eq(nft.holder, holder);

        // verify bid
        let bid: Bid = bids.get(nft_id);
        assert_eq(bid.bidder, winner);
        assert_eq(bid.amount, winner_amount);

        // update holder info
        nfts.set(
            nft_id,
            NftInfo {
                holder: winner,
                minter: nft.minter,
                hash: nft.hash,
                uri: nft.uri,
            },
        );

        // clear mappings
        bids.remove(nft_id);
        orders.remove(nft_id);
    }

    async transition set_admin(
        public admin_new: address,
    ) -> Future {
        return finalize_set_admin(
            self.caller,
            admin_new
        );
    }

    async function finalize_set_admin(
        caller: address,
        admin_new: address
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.admin);

        settings.set(
            true,
            Setting {
                admin: admin_new,
                operator: setting.operator,
                fee: setting.fee,
            },
        );
    }

    async transition set_operator(
        public operator_new: address,
    ) -> Future {
        return finalize_set_operator(
            self.caller,
            operator_new
        );
    }

    async function finalize_set_operator(
        caller: address,
        operator_new: address
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.admin);

        settings.set(
            true,
            Setting {
                admin: setting.admin,
                operator: operator_new,
                fee: setting.fee,
            },
        );
    }

    async transition set_fee(
        public fee_new: u64,
    ) -> Future {
        return finalize_set_fee(
            self.caller,
            fee_new,
        );
    }

    async function finalize_set_fee(
        caller: address,
        fee_new: u64,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.admin);

        settings.set(
            true,
            Setting {
                admin: setting.admin,
                operator: setting.operator,
                fee: fee_new,
            },
        );
    }

    async transition withdraw_fee(
        public fee_to_withdraw: u64,
        public recipient: address,
    ) -> Future {
        let f_credits_transfer_public: Future = credits.aleo/transfer_public(recipient, fee_to_withdraw);
        return finalize_withdraw_fee(
            self.caller,
            f_credits_transfer_public,
        );
    }

    async function finalize_withdraw_fee(
        caller: address,
        f_credits_transfer_public: Future,
    ) {
        f_credits_transfer_public.await();
        assert_eq(caller, settings.get(true).admin);
    }
}