# aigc.aleo program

## Struct

```js
struct TokenId {
    next_token_id: field,   // max nft id
}
```

```js
struct Field2 {
    first: field,   // the first half
    second: field,  // the second half
}
```

```js
struct NftHash {
    minter: address      // creator
    prompt: Field2,      // prompt command to generate image
    nonce: field,        // random number to unique nft
}
```

```js
struct NftInfo {
    owner: address, // owner address
    minter: address, // minter address
    hash: filed,     // bhp256_hash(NftHash)
    uri: Field2,      // image content ipfs url
}
```

```js
struct Order {
    owner: address,  // owner address
    minter: address, // minter address
    hash: field,     // bhp256_hash(NftHash)
    uri: Field2,     // image content ipfs url
    type: u8,        // order type, 0:non-trading 1:normal 2:auction（Todo）
    amount: field,   // minumum amount
    status: u8,      // order status, 0:non-trading 1:trading 2:canceled 3:finished
    deadline: field  // the timestamp to finish order -- blocknumber or timestamp
}
```

```js
record Nft {
    owner: address,         // NFT owner
    minter: address,        // NFT minter
    prompt: Field2,          // NFT prompt, hidden
    nonce: field             // random number to unique nft
    uri: Field2,             // NFT content
}
```

```js
record Bid {
    owner: address,     // bid owner
    bidder: address,    // bidder address
    hash: field,        // id
    amount: field,      // bidding amount
}
```

## Public states

### tokenId

mapping
Store the maximum tokenid.  
`tokenId` store: `bool => TokenId`;

### nfts

mapping
Store all the minted nfts.

`nfts` store: `id => NftInfo`  
`id` id++ from 1

### orders

mapping
Store all the orders.
`orders` store: `NftHash => Order`;

## Interfaces

### mint_nft

`mint_nft` used to mint nfts for aigc images
 nfts minted stored in `Nfts`

- NFT mint, permisionless。
  
inputs:

- `prompt` : Field2.private
  nft prompt

- `uri` : Field2
    image content

outputs:

- `NFT` record

usage:

```shell
run mint_nft:
leo run mint_nft
```

```shell
excute mint_nft:
snarkos developer execute -f $<fee> -r $<record> --query $<endpoint> --broadcast $<${endpoint}/testnet3/transaction/broadcast> -p $<private-key> $<program_id> ${function_id} $<inputs>
i.e:
snarkos developer execute 
-f 2509834 
-r "{  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,  microcredits: 93750000000000u64.private,  _nonce: 600042304734513817307279222414740026784347330221707613918989922910747206357group.public}" 
--query "http://localhost:3030" 
--broadcast "http://localhost:3030/testnet3/transaction/broadcast" 
-p "APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH" 
artgo_aigc_v1.aleo 
mint_nft "{
    first: 10000field,
    second: 10000field
}" "{
    first: 10000field,
    second: 10000field
}"
```

```shell
query nft:
i.e:
curl --location 'http://127.0.0.1:3030/testnet3/program/aigc.aleo/mapping/nfts/1field'


```

### place_order(TBD)

`place_order` used to start an order.

- place order, permisionless。

inputs:

- `NFT` record
  NFT to auction

- `type` order type
      0 - non-trading
      1 - normal
      2 - auction

- `amount` u128
  Minimum amount for auction

- `deadline` field
  the timestamp to finish order

outputs:

- `NFT` record to admin

usage:

```shell
TBD
```

### cancel_order(TBD)

`cancel_order` used to cancel an order.'

- cancel order, permisionless.

### bid_order (TBD)

`bid_order` to bid for NFT.

- bid order, permisionless 。

inputs:

- `hash` : field
   nft hash
  
- `amount` : u64
  bid amount

outputs:

- success --`Bid` record to admin, if amount greater than previous, refund the previous. Otherwise, tx will fail.

usage:

```shell
TBD
```

### finish_order (TBD)

`finish_order` to finish an order.

- finish order, only admin
- delete mapping when nft not sold.
- success or fail

inputs:

- `nft` : `NFT` record
   nft record
  
- `winner` : `Bid` record
  bid record

outputs:

- `NFT` record to winner

- `credit` record to seller

usage:

```shell
TBD
```

## Workflow (TBD)

![avatar](./artgo.png)

## Build Guide

To compile this Aleo program, run:

```bash
leo build
```

## Deploy Guide

To deploy this Aleo program, run:

```bash
i.e:
snarkos developer deploy 
--fee 1000001328000 
-r "{  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,  microcredits: 93750000000000u64.private,  _nonce: 878010960996471104548362432643577968735743754584843045001751072533354535962group.public}" 
--query "http://localhost:3030" 
--broadcast "http://localhost:3030/testnet3/transaction/broadcast" 
-p "APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH" 
artgo_aigc_v1.aleo
```

```bash

aigc program testnet3 deployed:


mapping query:

curl --location 'http://testnet3.artgo.app/testnet3/program/aigc.aleo/mapping/tokenId/true'
```
