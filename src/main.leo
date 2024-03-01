import credits.leo;

// The 'aigc_ver_0.aleo' program.
program aigc_ver_0.aleo{
    // optimize:
    // 0. limit program id into 10 bytes (gas saving)
    // 1. change nft id from field to u128
    // 2. mapping operators
    // 3. lock amount into program in {bid_order}
    // 4. add init function
    // 5. change deadline from field to u32
    // 6. add global setting
    // 7. remove bid amount overflow check
    // 8. finalize parameters: {place_order},{finish_order}
    // 9. transition parameters: {finish_order}
    // 10. some constants
    // 11. add deadline check in {bid_order}

    // discussion: lock nft into the contract? -> remove {handle_cancel_order}

    const THIS_ADDRESS: address = aleo1ax4yjycz4hezsd34urj6w5x8y4m7xhrh0f4few4xg05eylzapsrs3lax9n;
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

    struct Field2 {
        first: field,   
        second: field,
    }

    struct NftHash {
        minter: address,
        prompt: Field2,
        nonce: field,
    }

    struct NftInfo {
        holder: address,
        minter: address,
        hash: field,
        uri: Field2,
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
        prompt: Field2,
        nonce: field,
        uri: Field2,
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
        fee: u64,
    }

    transition init(
        public admin: address,
        public fee: u64
    ) {
        assert_eq(self.caller, INITIALIZER);

        return then finalize(
            admin,
            fee,
        );
    }

    finalize init(
        admin: address,
        fee: u64
    ) {
        assert_eq(settings.contains(true), false);

        settings.set(
            true,
            Setting {
                admin: admin,
                fee: fee,
            }
        );

        next_nft_id.set(
            true,
            1u128
        );
    }

    // mint aigc nft
    transition mint_nft (
        private prompt: Field2,
        public uri: Field2,
        public nonce: field
    ) -> Nft {
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

        return nft then finalize(
            self.caller,
            hash,
            uri,
        );
    }

    finalize mint_nft (
        holder: address,
        hash: field,
        uri: Field2,
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

    transition transfer_private_nft (
        nft_id: u128,
        nft: Nft,
        receiver: address
    ) -> Nft {
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

        return transferred then finalize(
            nft_id,
            hash,
            nft.uri,
            receiver,
        );
    }

    finalize transfer_private_nft (
        nft_id: u128,
        hash: field,
        uri: Field2,
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

    transition place_order (
        public nft_id: u128,
        private nft: Nft,
        public order_type: u8,
        public amount: u64,
        public deadline: u32,
        public admin_in: address
    ) -> Nft {
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
            owner: admin_in,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        return nft_transfer then finalize(
            admin_in,
            nft_id,
            hash,
            nft.uri,
            self.caller,
            order_type,
            amount,
            deadline,
        );
    }

    finalize place_order (
        admin_in: address,
        nft_id: u128,
        hash: field,
        uri: Field2,
        caller: address,
        order_type: u8,
        amount: u64,
        deadline: u32,
    ) {
        assert(deadline > block.height);

        let setting: Setting = settings.get(true);
        assert_eq(admin_in, setting.admin);
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

    transition update_order (
        public nft_id: u128,
        public new_amount: u64,
    ) {
        return then finalize(
            self.caller,
            nft_id,
            new_amount
        );
    }

    finalize update_order (
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

    transition cancel_order (
        private credit: credits.leo/credits,
        public fee: u64,
        public nft_id: u128,
        public admin_in: address,
    ) -> (credits.leo/credits, BidRecord) {
        let bid_record: BidRecord = BidRecord {
            owner: admin_in,
            bid_type: BID_TYPE_CANCEL,
            bidder: self.caller,
            nft_id: nft_id,
            amount: 0u64,
        };

        let change: credits = credits.leo/transfer_private_to_public(credit, admin_in, fee);
        return (change, bid_record) then finalize(
            self.caller,
            nft_id,
            fee,
            admin_in,
        );
    }

    finalize cancel_order (
        owner: address,
        nft_id: u128,
        fee: u64,
        admin_in: address,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(fee, setting.fee);
        assert_eq(admin_in, setting.admin);

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
    transition handle_cancel_order (
        public nft_id: u128,
        private nft: Nft,
        public receiver: address,
    ) -> Nft {
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

        return nft_transfer then finalize(
            nft_id,
            hash,
            nft.uri,
            receiver,
            self.caller,
        );
    }

    finalize handle_cancel_order (
        nft_id: u128,
        hash: field,
        uri: Field2,
        receiver: address,
        admin_in: address,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(admin_in, setting.admin);

        // verify nft
        let nft: NftInfo = nfts.get(nft_id);
        assert_eq(nft.hash, hash);
        assert_eq(nft.uri, uri);

        // vefiry order
        let order: Order = orders.get(nft_id);
        assert_eq(order.status, ORDER_STATUS_CANCELLED);
        assert_eq(receiver, order.holder);

        // clear mappings
        bids.remove(nft_id);
        orders.remove(nft_id);
    }

    transition bid_order (
        private credit: credits.leo/credits,
        public nft_id: u128,
        public amount: u64,
        public admin_in: address,
    ) -> (BidRecord, credits.leo/credits) {
        let bid_record: BidRecord = BidRecord {
            owner: admin_in,
            bid_type: BID_TYPE_BID,
            bidder: self.caller,
            nft_id: nft_id,
            amount: amount,
        };

        // lock credits in this program
        let change: credits = credits.leo/transfer_private_to_public(credit, THIS_ADDRESS, amount);
        return (bid_record, change) then finalize(
            self.caller,
            nft_id,
            amount,
            admin_in,
        );
    }

    finalize bid_order (
        caller: address,
        nft_id: u128,
        amount: u64,
        admin_in: address,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(admin_in, setting.admin);

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

    // ONLY ADMIN
    transition finish_order (
        public nft_id: u128,
        private nft: Nft,
        public holder: address,
        public fee: u64,
        public winner: address,
        public winner_amount: u64,
    ) -> (Nft){
        // transfer remaining amount
        credits.leo/transfer_public(holder, winner_amount - fee);

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

        return nft_transfer then finalize(
            nft_id,
            holder,
            hash,
            nft.uri,
            winner,
            winner_amount,
            fee,
            self.caller,
        );
    }

    finalize finish_order (
        nft_id: u128,
        holder: address,
        hash: field,
        uri: Field2,
        winner: address,
        winner_amount: u64,
        fee: u64,
        caller: address,
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.admin);
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


    transition set_admin(admin_new: address) {
        return then finalize(
            self.caller,
            admin_new
        );
    }

    finalize set_admin(
        caller: address,
        admin_new: address
    ) {
        let setting: Setting = settings.get(true);
        assert_eq(caller, setting.admin);

        settings.set(
            true,
            Setting {
                admin: admin_new,
                fee: setting.fee,
            },
        );
    }

//     transition set_fee(fee: u64) {
//         return then finalize(self.caller, fee);
//     }
//
//     finalize set_fee(public caller: address, fee: u64) {
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(caller, real_admin);
//
//         Mapping::set(fees, true, fee);
//     }
}