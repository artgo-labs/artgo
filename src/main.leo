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
        prompt: Field2,
    }

    struct NftInfo {
        holder: address,
        hash: field,
        uri: Field2,
    }

    record Nft {
        owner: address,
        holder: address,
        prompt: Field2,
        uri: Field2,
    }

    record Bid {
        owner: address,     // bid owner
        bidder: address,    // bidder address
        nft_id: field,      // id
        gates: u64,         // bid amount
        is_winner: bool     // bid result
    }

    //nft id --> nft info
    mapping nfts: field => NftInfo;
    //true --> max token id
    mapping tokenId: bool => TokenId;

    // mint aigc nft
    transition mint_nft(private prompt: Field2, public uri: Field2) -> Nft {

        let digest: NftHash = NftHash {
            prompt: prompt,
        };

        let hash: field = BHP256::hash_to_field(digest);

        let nft: Nft = Nft {
            owner: self.caller,
            holder: self.caller,
            prompt: prompt,
            uri: uri,
        };

        return nft then finalize(self.caller, hash, uri);
    }

    finalize mint_nft(holder: address, hash: field, uri: Field2) {
        let token_id: TokenId = Mapping::get_or_use(tokenId, true, TokenId {
            next_token_id: 1field,
        });

        let num: field = token_id.next_token_id;
        Mapping::set(tokenId, true, TokenId {
            next_token_id: num + 1field,
        });

        let info: NftInfo = NftInfo{
            holder: holder,
            hash: hash,
            uri: uri,
        };
        Mapping::set(nfts, num, info);
    }
}