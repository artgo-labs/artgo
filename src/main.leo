    // The 'artgo_aigc_v1.aleo' program.
program artgo_aigc_v1.aleo{

    struct Field2 {
        first: field,   
        second: field,
    }

    struct TokenId {
        next_token_id: field,
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

    record Nft {
        owner: address,
        minter: address,
        prompt: Field2,
        nonce: field,
        uri: Field2,
    }

    record Bid {
        owner: address,     // bid owner
        bidder: address,    // bidder address
        hash: field,
        amount: field,
    }

    //nft id --> nft info
    mapping nfts: field => NftInfo;
    //true --> max token id
    mapping tokenId: bool => TokenId;
    //true --> admin
    mapping admin: bool => address;
    //nft hash --> Order
    mapping orders: field => Order;

    // mint aigc nft
    transition mint_nft (private prompt: Field2, public uri: Field2, nonce: field) -> Nft {

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

    finalize mint_nft(holder: address, hash: field, uri: Field2, order: Order) {
        let token_id: TokenId = Mapping::get_or_use(tokenId, true, TokenId {
            next_token_id: 1field,
        });

        let num: field = token_id.next_token_id;
        Mapping::set(tokenId, true, TokenId {
            next_token_id: num + 1field,
        });

        let info: NftInfo = NftInfo{
            holder: holder,
            minter: holder,
            hash: hash,
            uri: uri,
        };
        Mapping::set(nfts, num, info);
        //update orders
        assert(!Mapping::contains(orders, hash));
        Mapping::set(orders, hash, order);
    }

    transition transfer_private (nft: Nft, receiver: address) -> Nft {
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

    transition place_order (nft: Nft, order_type: u8, amount: field, deadline: field, admin_in: address) -> Nft {
        //Only support buy / sell now
        assert(order_type <= 1u8);    

        let digest: NftHash = NftHash {
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
        };

        let hash: field = BHP256::hash_to_field(digest);

        let nft_new : Nft = Nft {
            owner: admin_in,
            minter: nft.minter,
            prompt: nft.prompt,
            nonce: nft.nonce,
            uri: nft.uri,
        };

        return nft_new then finalize(admin_in, hash, order_type, amount, deadline);
    }

    finalize place_order (admin_in: address, hash: field, order_type: u8, amount: field, deadline: field) {
        //Get admin
        assert(Mapping::contains(admin, true));
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(admin_inuse, admin_in);

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

    //admin functions
    transition init() {
        return then finalize(self.caller);
    }

    finalize init(public caller: address) {
       let admin_inuse: address = Mapping::get_or_use(admin, true, 
            aleo12n3kz2wzrljvhp9zkn9zety54wz8mlmlakzzkrs6znaz028wjczqpe8x3j);
        assert_eq(admin_inuse, caller);
        Mapping::set(admin, true, admin_inuse);
    }

    transition change_admin (new: address) {
        return then finalize(self.caller, new);
    }

    finalize change_admin (caller: address, new: address) {
        let admin_inuse: address = Mapping::get(admin, true);
        assert_eq(caller, admin_inuse);
        Mapping::set(admin, true, new);
    
    }
}