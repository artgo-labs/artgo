import credits.leo;

// The 'artgo_aigc_v1.aleo' program.
program artgo_aigc_v1.aleo{

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
        minter: address,
        hash: field,
        uri: Field2,
        order_type: u8,
        amount: u128,
        status: u8,
        deadline: field,
    }

    struct Bid {
        bidder: address,    // bidder address
        hash: field,
        amount: u128,
    }

    record BidRecord {
        owner: address,     
        bidder: address,
        hash: field,
        amount: field,
    }

    record Nft {
        owner: address,
        minter: address,
        prompt: Field2,
        nonce: field,
        uri: Field2,
    }

    //nft id --> nft info
    mapping nfts: field => NftInfo;
    //true --> max token id
    mapping tokenId: bool => field;
    //true --> admin
    mapping admin: bool => address;
    //nft hash --> Order
    mapping orders: field => Order;
    //nft hash --> bid
    mapping bids: field => Bid;

    // mint aigc nft
    transition mint_nft (
        private prompt: Field2, 
        public uri: Field2, 
        public nonce: field
    ) -> Nft {

        let digest: NftHash = NftHash {
            minter: self.caller,
            prompt: prompt,
            nonce: nonce,
        };

        let hash: field = BHP256::hash_to_field(digest);

        let nft: Nft = Nft {
            owner: self.caller,
            minter: self.caller,
            prompt: prompt,
            nonce: nonce,
            uri: uri,
        };

        let order: Order = Order{
            holder: self.caller,
            minter: self.caller,
            hash: hash,
            uri: uri,
            order_type: 0u8,
            amount: 0u128,
            status: 0u8,
            deadline: 0field,
        };

        return nft then finalize(self.caller, hash, uri, order);
    }

    finalize mint_nft (
        holder: address, 
        hash: field, 
        uri: Field2, 
        order: Order
    ) {
        let token_id: field = Mapping::get_or_use(tokenId, true, 1field);
        Mapping::set(tokenId, true, token_id + 1field);

        let info: NftInfo = NftInfo{
            holder: holder,
            minter: holder,
            hash: hash,
            uri: uri,
        };
        Mapping::set(nfts, token_id, info);
        // update orders
        assert(!Mapping::contains(orders, hash));
        Mapping::set(orders, hash, order);
    }

    transition transfer_private_nft (
        nft: Nft, 
        receiver: address
    ) -> Nft {
        //verify owner
        assert(nft.owner == self.caller);

        // Produce a Nft record for the specified receiver.
        let transferred: Nft = Nft {
            owner: receiver,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        return transferred;
    }

    transition place_order (
        private nft: Nft, 
        public order_type: u8, 
        public amount: field, 
        public deadline: field, 
        public admin_in: address
    ) -> Nft {
        //Only support buy / sell atm
        assert(order_type == 1u8);    
        assert(amount > 0field && amount <= 18446744073709551615field);

        let digest: NftHash = NftHash {
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
        };

        let hash: field = BHP256::hash_to_field(digest);

        // find order based on hash offchain
        let nft_transfer : Nft = Nft {
            owner: admin_in,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        return nft_transfer then finalize(admin_in, hash, order_type, amount, deadline);
    }

    finalize place_order (
        admin_in: address, 
        hash: field, 
        order_type: u8, 
        amount: field, 
        deadline: field
    ) {
        //Get admin
        assert(Mapping::contains(admin, true));
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(admin_inuse, admin_in);

        //update order information
        assert(Mapping::contains(orders, hash));
        let order: Order = Mapping::get(orders, hash);
        let order_update : Order = Order {
            holder: order.holder,
            minter: order.minter,
            hash: order.hash,
            uri: order.uri,
            amount: amount as u128,
            order_type: order_type,
            status: 1u8,
            deadline: 0field,
        };

        Mapping::set(orders, hash, order_update);
    }

    transition bid_order (
        private credit: credits.leo/credits, 
        public hash: field, 
        public amount: field,
        public admin_in: address,
    ) -> (BidRecord, credits.leo/credits) {
        assert(amount > 0field && amount <= 18446744073709551615field);
        //Todo:: charge fee
        let bid_record: BidRecord = BidRecord {
            owner: admin_in,
            bidder: self.caller,
            hash: hash,
            amount: amount,
        };
        let change: credits = credits.leo/transfer_private_to_public(credit, admin_in, amount as u64);
        return (bid_record, change) then finalize(self.caller, hash, amount as u128 , admin_in);
    }

    finalize bid_order (
        caller: address,
        hash: field,
        amount: u128,
        admin_in: address,
    ) {
        //verify admin
        assert(Mapping::contains(admin, true));
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(admin_inuse, admin_in);

        let bid : Bid = Bid {
            bidder: caller,
            hash: hash,
            amount : amount,
        };
        Mapping::set(bids, hash, bid);

        assert(Mapping::contains(orders, hash));
        let order: Order = Mapping::get(orders, hash);
        assert(order.status == 1u8);
        assert(amount as u128 >= order.amount);

        let order_update : Order = Order {
            holder: order.holder,
            minter: order.minter,
            hash: order.hash,
            uri: order.uri,
            amount: order.amount,
            order_type: order.order_type,
            status: 3u8,
            deadline: 0field,
        };

        Mapping::set(orders, hash, order_update);
    }

    transition finish_order (
        private nft: Nft,
        public winner: address,
        public winner_amount: field,
        public admin_in: address,
    ) -> (Nft){
        //Todo:: charge fee
        assert(winner_amount > 0field && winner_amount <= 18446744073709551615field);
        credits.leo/transfer_public(winner, winner_amount as u64);

        let digest: NftHash = NftHash {
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
        };

        let hash: field = BHP256::hash_to_field(digest);
        let nft_transfer : Nft = Nft {
            owner: winner,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        return nft_transfer then finalize(hash, winner, winner_amount as u128, admin_in);
    }

    finalize finish_order (
        hash: field,
        winner: address,
        winner_amount: u128,
        admin_in: address
    ) {
        //verify admin
        assert(Mapping::contains(admin, true));
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(admin_inuse, admin_in);

        //verify order
        assert(Mapping::contains(orders, hash));
        let order: Order = Mapping::get(orders, hash);
        assert_eq(order.status, 3u8);

        //verify bid
        assert(Mapping::contains(bids, hash));
        let bid: Bid = Mapping::get(bids, hash);
        assert_eq(bid.bidder, winner);
        assert(bid.amount == winner_amount);

        //Todo::clear mappings
    }

    //Todo::cancel order
    //Todo::handle cancel order

    //admin functions
    transition set_admin(admin_new: address) {
        return then finalize(self.caller, admin_new);
    }

    finalize set_admin(public caller: address, admin_new: address) {
       let admin_inuse: address = Mapping::get_or_use(admin, true, aleo12n3kz2wzrljvhp9zkn9zety54wz8mlmlakzzkrs6znaz028wjczqpe8x3j);
        assert_eq(admin_inuse, caller);
        Mapping::set(admin, true, admin_new);
    }

    transition change_admin (admin_new: address) {
        return then finalize(self.caller, admin_new);
    }

    finalize change_admin (caller: address, admin_new: address) {
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(caller, admin_inuse);
        Mapping::set(admin, true, admin_new);
    }

    //Todo:: change fee setting
}