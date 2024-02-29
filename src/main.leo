import credits.leo;

// The 'aigc_ver_0.aleo' program.
program aigc_ver_0.aleo{
    // optimize:
    // 1. change nft id from field to u128
    // 2. mapping operator
    // 3. lock amount into program
    // 4. add init function
    // 5. change deadline from field to u128
    // 6. add global setting

    const THIS_ADDRESS: address = aleo1ax4yjycz4hezsd34urj6w5x8y4m7xhrh0f4few4xg05eylzapsrs3lax9n;
    const INITIALIZER: address = aleo1qdtufktf3xj78qdxh9s9jerelrmjukt7rn5l04nx8nhr7k8spcpsyf9eye;

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
        nft_id: field,
        order_type: u8,
        amount: u64,
        status: u8,
        deadline: field,
    }

    struct Bid {
        bidder: address,    // bidder address
        nft_id: field,
        amount: u64,
    }

    record BidRecord {
        bid_type: u8,           //1-bid, 2-cancel
        owner: address,     
        bidder: address,
        nft_id: field,
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
    mapping orders: field => Order;
    //nft id --> bid
    mapping bids: field => Bid;
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

        return nft then finalize(self.caller, hash, uri);
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

//     transition transfer_private_nft (
//         nft_id: field,
//         nft: Nft,
//         receiver: address
//     ) -> Nft {
//         //verify owner
//         assert(nft.owner == self.caller);
//
//         // Produce a Nft record for the specified receiver.
//         // check validity
//         let digest: NftHash = NftHash {
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//         };
//
//         let hash: field = BHP256::hash_to_field(digest);
//
//         let transferred: Nft = Nft {
//             owner: receiver,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         return transferred then finalize(nft_id, hash, nft.uri, receiver);
//     }
//
//     finalize transfer_private_nft (
//         nft_id: field,
//         hash: field,
//         uri: Field2,
//         receiver: address,
//     ) {
//         let nft: NftInfo = Mapping::get(nfts, nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//
//         //change holder info
//         let info: NftInfo = NftInfo {
//             holder: receiver,
//             minter: nft.minter,
//             hash: nft.hash,
//             uri: nft.uri,
//         };
//         Mapping::set(nfts, nft_id, info);
//     }
//
//     transition place_order (
//         public nft_id: field,
//         private nft: Nft,
//         public order_type: u8,
//         public amount: u64,
//         public deadline: field,
//         public admin_in: address
//     ) -> Nft {
//         //Only support buy / sell atm
//         assert(order_type == 1u8);
//         assert(amount > 0u64 && amount <= 18446744073709551615u64);
//
//         let digest: NftHash = NftHash {
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//         };
//         let hash: field = BHP256::hash_to_field(digest);
//
//         let order : Order = Order {
//             holder: self.caller,
//             nft_id: nft_id,
//             amount: amount,
//             order_type: order_type,
//             status: 1u8,
//             deadline: 0field,
//         };
//
//         // find order based on hash offchain
//         let nft_transfer : Nft = Nft {
//             owner: admin_in,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         return nft_transfer then finalize(admin_in, nft_id, hash, nft.uri, order);
//     }
//
//     finalize place_order (
//         admin_in: address,
//         nft_id: field,
//         hash: field,
//         uri: Field2,
//         order: Order
//     ) {
//         //Get admin
//         assert(Mapping::contains(admin, true));
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(real_admin, admin_in);
//
//         let nft: NftInfo = Mapping::get(nfts, nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//
//         //update order information
//         assert(Mapping::contains(fees, true));
//         let real_fee: u64 = Mapping::get(fees, true);
//         assert(order.amount >= real_fee);  //check greater than fee
//
//         assert(!Mapping::contains(orders, nft_id));
//         Mapping::set(orders, nft_id, order);
//     }
//
//     transition update_order (
//         public nft_id: field,
//         public new_amount: u64,
//     ) {
//         assert(new_amount > 0u64 && new_amount <= 18446744073709551615u64);
//         return then finalize(self.caller, nft_id, new_amount);
//     }
//
//     finalize update_order (
//         owner: address,
//         nft_id: field,
//         amount_new: u64,
//     ) {
//         let order: Order = Mapping::get(orders, nft_id);
//         assert(order.status == 1u8);
//         assert(owner == order.holder);
//
//         assert(Mapping::contains(fees, true));
//         let real_fee: u64 = Mapping::get(fees, true);
//         assert(amount_new >= real_fee);  //check greater than fee
//
//         let order_update : Order = Order {
//             holder: order.holder,
//             nft_id: order.nft_id,
//             amount: amount_new,
//             order_type: order.order_type,
//             status: order.status,
//             deadline: order.deadline,
//         };
//
//         Mapping::set(orders, nft_id, order_update);
//     }
//
//     transition cancel_order (
//         private credit: credits.leo/credits,
//         public fee: u64,
//         public nft_id: field,
//         public admin_in: address,
//     ) -> (credits.leo/credits, BidRecord) {
//         //charge fee
//         assert(fee <= credit.microcredits);
//
//         let bid_record: BidRecord = BidRecord {
//             owner: admin_in,
//             bid_type: 2u8,
//             bidder: self.caller,
//             nft_id: nft_id,
//             amount: 0u64,
//         };
//         let change:credits = credits.leo/transfer_private_to_public(credit, admin_in, fee);
//         return (change, bid_record) then finalize(self.caller, nft_id, fee, admin_in);
//
//     }
//
//     finalize cancel_order (
//         owner: address,
//         nft_id: field,
//         fee: u64,
//         admin_in: address,
//     ) {
//         //charge 4 credits first, will change to settings later
//         assert(Mapping::contains(fees, true));
//         let real_fee: u64 = Mapping::get(fees, true);
//         assert_eq(real_fee, fee);
//
//         let order: Order = Mapping::get(orders, nft_id);
//         assert(order.status == 1u8);
//         assert(owner == order.holder);
//
//         assert(Mapping::contains(admin, true));
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(real_admin, admin_in);
//
//         let order_update : Order = Order {
//             holder: order.holder,
//             nft_id: order.nft_id,
//             amount: order.amount,
//             order_type: order.order_type,
//             status: 2u8,
//             deadline: order.deadline,
//         };
//
//         Mapping::set(orders, nft_id, order_update);
//     }
//
//     //handle cancel order, delete states
//     transition handle_cancel_order (
//         public nft_id: field,
//         private nft: Nft,
//         public receiver: address,
//     ) -> Nft {
//
//         let nft_transfer : Nft = Nft {
//             owner: receiver,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         let digest: NftHash = NftHash {
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//         };
//         let hash: field = BHP256::hash_to_field(digest);
//
//         return nft_transfer then finalize(nft_id, hash, nft.uri, receiver, self.caller);
//     }
//
//     finalize handle_cancel_order (
//         nft_id: field,
//         hash: field,
//         uri: Field2,
//         receiver: address,
//         admin_in: address,
//     ) {
//         //verify admin
//         assert(Mapping::contains(admin, true));
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(real_admin, admin_in);
//
//         //verify nft
//         let nft: NftInfo = Mapping::get(nfts, nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//
//         //vefiry order
//         let order: Order = Mapping::get(orders, nft_id);
//         assert(order.status == 2u8);
//         assert(receiver == order.holder);
//
//         //clear mappings
//         Mapping::remove(bids, nft_id);
//         Mapping::remove(orders, nft_id);
//     }
//
//     transition bid_order (
//         private credit: credits.leo/credits,
//         public nft_id: field,
//         public amount: u64,
//         public admin_in: address,
//     ) -> (BidRecord, credits.leo/credits) {
//         assert(amount > 0u64 && amount <= 18446744073709551615u64);
//         let bid_record: BidRecord = BidRecord {
//             owner: admin_in,
//             bid_type: 1u8,
//             bidder: self.caller,
//             nft_id: nft_id,
//             amount: amount,
//         };
//         let change: credits = credits.leo/transfer_private_to_public(credit, admin_in, amount);
//         return (bid_record, change) then finalize(self.caller, nft_id, amount, admin_in);
//     }
//
//     finalize bid_order (
//         caller: address,
//         nft_id: field,
//         amount: u64,
//         admin_in: address,
//     ) {
//         //verify admin
//         assert(Mapping::contains(admin, true));
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(real_admin, admin_in);
//
//         //add bid
//         let bid : Bid = Bid {
//             bidder: caller,
//             nft_id: nft_id,
//             amount : amount,
//         };
//         Mapping::set(bids, nft_id, bid);
//
//         //verify order
//         assert(Mapping::contains(orders, nft_id));
//         let order: Order = Mapping::get(orders, nft_id);
//         assert(order.status == 1u8);
//         assert(amount >= order.amount);
//
//         //update order
//         let order_update : Order = Order {
//             holder: order.holder,
//             nft_id: order.nft_id,
//             amount: order.amount,
//             order_type: order.order_type,
//             status: 3u8,
//             deadline: 0field,
//         };
//
//         Mapping::set(orders, nft_id, order_update);
//     }
//
//     transition finish_order (
//         public nft_id: field,
//         private nft: Nft,
//         public holder: address,
//         public fee: u64,
//         public winner: address,
//         public winner_amount: u64,
//         public admin_in: address,
//     ) -> (Nft){
//         //charge fee
//         assert(winner_amount >= fee && winner_amount <= 18446744073709551615u64);
//         assert_eq(self.caller, admin_in);
//
//         //transfer remaining amount
//         credits.leo/transfer_public(holder, winner_amount - fee);
//
//         let digest: NftHash = NftHash {
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//         };
//
//         let hash: field = BHP256::hash_to_field(digest);
//         let nft_transfer : Nft = Nft {
//             owner: winner,
//             minter: nft.minter,
//             prompt: nft.prompt,
//             nonce: nft.nonce,
//             uri: nft.uri,
//         };
//
//         return nft_transfer then finalize(nft_id, holder, hash, nft.uri, winner, winner_amount, fee, admin_in);
//     }
//
//     finalize finish_order (
//         nft_id: field,
//         holder: address,
//         hash: field,
//         uri: Field2,
//         winner: address,
//         winner_amount: u64,
//         fee: u64,
//         admin_in: address
//     ) {
//         //verify admin
//         assert(Mapping::contains(admin, true));
//         let real_admin: address = Mapping::get(admin, true);
//         assert_eq(real_admin, admin_in);
//
//         assert(Mapping::contains(fees, true));
//         let real_fee: u64 = Mapping::get(fees, true);
//         assert_eq(real_fee, fee);
//
//         //verify order
//         assert(Mapping::contains(orders, nft_id));
//         let order: Order = Mapping::get(orders, nft_id);
//         assert_eq(order.status, 3u8);
//
//         //verify nft
//         let nft: NftInfo = Mapping::get(nfts, nft_id);
//         assert_eq(nft.hash, hash);
//         assert_eq(nft.uri, uri);
//         assert_eq(nft.holder, holder);
//
//         //verify bid
//         assert(Mapping::contains(bids, nft_id));
//         let bid: Bid = Mapping::get(bids, nft_id);
//         assert_eq(bid.bidder, winner);
//         assert(bid.amount == winner_amount);
//
//         //change holder info
//         let info: NftInfo = NftInfo {
//             holder: winner,
//             minter: nft.minter,
//             hash: nft.hash,
//             uri: nft.uri,
//         };
//         Mapping::set(nfts, nft_id, info);
//
//         //clear mappings
//         Mapping::remove(bids, nft_id);
//         Mapping::remove(orders, nft_id);
//     }
//
//     //admin functions
//
//     transition set_admin(admin_new: address) {
//         return then finalize(self.caller, admin_new);
//     }
//
//     finalize set_admin(public caller: address, admin_new: address) {
//        let real_admin: address = Mapping::get_or_use(admin, true, aleo12n3kz2wzrljvhp9zkn9zety54wz8mlmlakzzkrs6znaz028wjczqpe8x3j);
//         assert_eq(real_admin, caller);
//         Mapping::set(admin, true, admin_new);
//     }
//
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