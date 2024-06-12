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
//
//     transition place_order (
//         public nft_id: u128,
//         private nft: Nft,
//         public order_type: u8,
//         public amount: u64,
//         public deadline: u32,
//         public operator_in: address
//     ) -> Nft {
//         // only support buy / sell atm
//         assert_eq(order_type, ORDER_TYPE_NORMAL);
//
//         let hash: field = BHP256::hash_to_field(
//             NftHash {
//                 minter: nft.minter,
//                 prompt: nft.prompt,
//                 nonce: nft.nonce,
//             }
//         );
//
//         // find order based on hash offchain
//         let nft_transfer : Nft = Nft {
//             owner: operator_in,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         return nft_transfer then finalize(
//             operator_in,
//             nft_id,
//             hash,
//             nft.uri,
//             self.caller,
//             order_type,
//             amount,
//             deadline,
//         );
//     }
//
//     finalize place_order (
//         operator_in: address,
//         nft_id: u128,
//         hash: field,
//         uri: [u128;3],
//         caller: address,
//         order_type: u8,
//         amount: u64,
//         deadline: u32,
//     ) {
//         assert(deadline > block.height);
//
//         let setting: Setting = settings.get(true);
//         assert_eq(operator_in, setting.operator);
//         assert(amount >= setting.fee);
//
//         let nft: NftInfo = Mapping::get(nfts, nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//
//         // update order information
//         assert_eq(orders.contains(nft_id), false);
//         orders.set(
//             nft_id,
//             Order {
//                 holder: caller,
//                 nft_id: nft_id,
//                 amount: amount,
//                 order_type: order_type,
//                 status: ORDER_STATUS_TRADING,
//                 deadline: deadline,
//             },
//         );
//     }
//
//     transition update_order (
//         public nft_id: u128,
//         public new_amount: u64,
//     ) {
//         return then finalize(
//             self.caller,
//             nft_id,
//             new_amount
//         );
//     }
//
//     finalize update_order (
//         owner: address,
//         nft_id: u128,
//         amount_new: u64,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert(amount_new >= setting.fee);
//
//         let order: Order = orders.get(nft_id);
//         assert_eq(order.status, ORDER_STATUS_TRADING);
//         assert_eq(owner, order.holder);
//
//         orders.set(
//             nft_id,
//             Order {
//                 holder: order.holder,
//                 nft_id: order.nft_id,
//                 amount: amount_new,
//                 order_type: order.order_type,
//                 status: order.status,
//                 deadline: order.deadline,
//             },
//         );
//     }
//
//     transition cancel_order (
//         private credit: credits.leo/credits,
//         public fee: u64,
//         public nft_id: u128,
//         public operator_in: address,
//     ) -> (credits.leo/credits, BidRecord) {
//         let bid_record: BidRecord = BidRecord {
//             owner: operator_in,
//             bid_type: BID_TYPE_CANCEL,
//             bidder: self.caller,
//             nft_id: nft_id,
//             amount: 0u64,
//         };
//
//         // lock fee in this program
//         let change: credits = credits.leo/transfer_private_to_public(credit, THIS_ADDRESS, fee);
//         return (change, bid_record) then finalize(
//             self.caller,
//             nft_id,
//             fee,
//             operator_in,
//         );
//     }
//
//     finalize cancel_order (
//         owner: address,
//         nft_id: u128,
//         fee: u64,
//         operator_in: address,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(fee, setting.fee);
//         assert_eq(operator_in, setting.operator);
//
//         let order: Order = orders.get(nft_id);
//         assert_eq(order.status, ORDER_STATUS_TRADING);
//         assert_eq(owner, order.holder);
//
//         orders.set(
//             nft_id,
//             Order {
//                 holder: order.holder,
//                 nft_id: order.nft_id,
//                 amount: order.amount,
//                 order_type: order.order_type,
//                 status: ORDER_STATUS_CANCELLED,
//                 deadline: order.deadline,
//             },
//         );
//     }
//
//     // handle cancel order, delete states
//     transition handle_cancel_order (
//         public nft_id: u128,
//         private nft: Nft,
//         public receiver: address,
//     ) -> Nft {
//         let nft_transfer : Nft = Nft {
//             owner: receiver,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         let hash: field = BHP256::hash_to_field(
//             NftHash {
//                 minter: nft.minter,
//                 prompt: nft.prompt,
//                 nonce: nft.nonce,
//             },
//         );
//
//         return nft_transfer then finalize(
//             nft_id,
//             hash,
//             nft.uri,
//             receiver,
//             self.caller,
//         );
//     }
//
//     finalize handle_cancel_order (
//         nft_id: u128,
//         hash: field,
//         uri: [u128;3],
//         receiver: address,
//         caller: address,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(caller, setting.operator);
//
//         // verify nft
//         let nft: NftInfo = nfts.get(nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//
//         // verify order
//         let order: Order = orders.get(nft_id);
//         assert_eq(order.status, ORDER_STATUS_CANCELLED);
//         assert_eq(receiver, order.holder);
//
//         // clear mappings
//         bids.remove(nft_id);
//         orders.remove(nft_id);
//     }
//
//     transition bid_order (
//         private credit: credits.leo/credits,
//         public nft_id: u128,
//         public amount: u64,
//         public operator_in: address,
//     ) -> (BidRecord, credits.leo/credits) {
//         let bid_record: BidRecord = BidRecord {
//             owner: operator_in,
//             bid_type: BID_TYPE_BID,
//             bidder: self.caller,
//             nft_id: nft_id,
//             amount: amount,
//         };
//
//         // lock credits in this program
//         let change: credits = credits.leo/transfer_private_to_public(credit, THIS_ADDRESS, amount);
//         return (bid_record, change) then finalize(
//             self.caller,
//             nft_id,
//             amount,
//             operator_in,
//         );
//     }
//
//     finalize bid_order (
//         caller: address,
//         nft_id: u128,
//         amount: u64,
//         operator_in: address,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(operator_in, setting.operator);
//
//         // add bid
//         bids.set(
//             nft_id,
//             Bid {
//                 bidder: caller,
//                 nft_id: nft_id,
//                 amount : amount,
//             },
//         );
//
//         // verify order
//         let order: Order = orders.get(nft_id);
//         assert_eq(order.status, ORDER_STATUS_TRADING);
//         assert(amount >= order.amount);
//         // deadline check
//         assert(block.height < order.deadline);
//
//         // update order
//         orders.set(
//             nft_id,
//             Order {
//                 holder: order.holder,
//                 nft_id: order.nft_id,
//                 amount: order.amount,
//                 order_type: order.order_type,
//                 status: ORDER_STATUS_FINISHED,
//                 deadline: order.deadline,
//             },
//         );
//     }
//
//     // ONLY OPERATOR
//     transition finish_order (
//         public nft_id: u128,
//         private nft: Nft,
//         public holder: address,
//         public fee: u64,
//         public winner: address,
//         public winner_amount: u64,
//     ) -> (Nft){
//         // transfer remaining amount
//         credits.leo/transfer_public(holder, winner_amount - fee);
//
//         let hash: field = BHP256::hash_to_field(
//             NftHash {
//                 minter: nft.minter,
//                 prompt: nft.prompt,
//                 nonce: nft.nonce,
//             },
//         );
//
//         let nft_transfer : Nft = Nft {
//             owner: winner,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         return nft_transfer then finalize(
//             nft_id,
//             holder,
//             hash,
//             nft.uri,
//             winner,
//             winner_amount,
//             fee,
//             self.caller,
//         );
//     }
//
//     finalize finish_order (
//         nft_id: u128,
//         holder: address,
//         hash: field,
//         uri: [u128;3],
//         winner: address,
//         winner_amount: u64,
//         fee: u64,
//         caller: address,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(caller, setting.operator);
//         assert_eq(fee, setting.fee);
//
//         // verify order status
//         assert_eq(orders.get(nft_id).status, ORDER_STATUS_FINISHED);
//
//         let nft: NftInfo = nfts.get(nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//         assert_eq(nft.holder, holder);
//
//         // verify bid
//         let bid: Bid = bids.get(nft_id);
//         assert_eq(bid.bidder, winner);
//         assert_eq(bid.amount, winner_amount);
//
//         // update holder info
//         nfts.set(
//             nft_id,
//             NftInfo {
//                 holder: winner,
//                 minter: nft.minter,
//                 hash: nft.hash,
//                 uri: nft.uri,
//             },
//         );
//
//         // clear mappings
//         bids.remove(nft_id);
//         orders.remove(nft_id);
//     }
//
//     transition set_admin(
//         public admin_new: address,
//     ) {
//         return then finalize(
//             self.caller,
//             admin_new
//         );
//     }
//
//     finalize set_admin(
//         caller: address,
//         admin_new: address
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(caller, setting.admin);
//
//         settings.set(
//             true,
//             Setting {
//                 admin: admin_new,
//                 operator: setting.operator,
//                 fee: setting.fee,
//             },
//         );
//     }
//
//     transition set_operator(
//         public operator_new: address,
//     ) {
//         return then finalize(
//             self.caller,
//             operator_new
//         );
//     }
//
//     finalize set_operator(
//         caller: address,
//         operator_new: address
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(caller, setting.admin);
//
//         settings.set(
//             true,
//             Setting {
//                 admin: setting.admin,
//                 operator: operator_new,
//                 fee: setting.fee,
//             },
//         );
//     }
//
//     transition set_fee(
//         public fee_new: u64,
//     ) {
//         return then finalize(
//             self.caller,
//             fee_new,
//         );
//     }
//
//     finalize set_fee(
//         caller: address,
//         fee_new: u64,
//     ) {
//         let setting: Setting = settings.get(true);
//         assert_eq(caller, setting.admin);
//
//         settings.set(
//             true,
//             Setting {
//                 admin: setting.admin,
//                 operator: setting.operator,
//                 fee: fee_new,
//             },
//         );
//     }
//
//     transition withdraw_fee(
//         public fee_to_withdraw: u64,
//         public recipient: address,
//     ) {
//         credits.leo/transfer_public(recipient, fee_to_withdraw);
//         return then finalize(
//             self.caller,
//         );
//     }
//
//     finalize withdraw_fee(
//         caller: address,
//     ) {
//         assert_eq(caller, settings.get(true).admin);
//     }
}