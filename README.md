# aigc.aleo program

## Struct

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
    holder: address, // owner address
    minter: address, // minter address
    hash: filed,     // bhp256_hash(NftHash)
    uri: Field2,      // image content ipfs url
}
```

```js
struct Order {
    holder: address,  // owner address
    minter: address, // minter address
    hash: field,     // bhp256_hash(NftHash)
    uri: Field2,     // image content ipfs url
    order_type: u8,        // order type, 0:non-trading 1:normal 2:auction（Todo）
    amount: u128,   // minumum amount
    status: u8,      // order status, 0:non-trading 1:trading 2:canceled 3:finished
    deadline: field  // the timestamp to finish order -- blocknumber or timestamp
}
```

```js
struct Bid {
    bidder: address,    // bidder address
    hash: field,        // id
    amount: u128,      // bidding amount
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


## Public states

### tokenId

mapping
Store the maximum tokenid.  
`tokenId` store: `bool => field`;

### nfts

mapping
Store all the minted nfts.

`nfts` store: `id => NftInfo`  
`id` id++ from 1

### admin

mapping
Store admin.
`admin` store: `bool => address`;

### orders

mapping
Store all the orders.
`orders` store: `field => Order`;

### bids

mapping
Store all the bids.
`bids` store: `field => Bid`;

## Interfaces

### mint_nft

`mint_nft` used to mint nfts for aigc images
 nfts minted stored in `Nfts`

- NFT mint, permisionless。
  
inputs:

- `prompt` : Field2.private
  nft prompt

- `uri` : Field2.public
    image content

- `nonce` : field.public
    random unique number

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

### transfer_private_nft

`transfer_private_nft` used to tranfer nft.

- transfer nft, permisionless.

inputs:

- `NFT` record
  NFT to auction

- `receiver` address
  Minimum amount for auction

outputs:

- `NFT` record to receiver

usage:

```shell
TBD
```

### place_order

`place_order` used to start an order.

- place order, permisionless。

inputs:

- `NFT` record
  NFT to auction

- `order_type` order type
      0 - non-trading
      1 - normal
      2 - auction

- `amount` field
  Minimum amount for auction

- `deadline` field
  the timestamp to finish order

- `admin_in` address
  admin address

outputs:

- `NFT` record to admin

usage:

```shell
TBD
```

### cancel_order(TBD)

`cancel_order` used to cancel an order.'

- cancel order, permisionless.

inputs:

- `hash` : field
   nft hash
  
usage:

```shell
TBD
```

### bid_order

`bid_order` to bid for NFT.

- bid order, permisionless.

inputs:

- `credit` : Record
   Aleo Credit record

- `hash` : field
   nft hash
  
- `amount` : field
  bid amount

- `admin_in` address
  admin address

outputs:

- success --`Bid` record to admin, if amount greater than previous, refund the previous. Otherwise, tx will fail.

usage:

```shell
TBD
```

### finish_order

`finish_order` to finish an order.

- finish order, only admin
- delete mapping when nft not sold.

inputs:

- `nft` : `NFT` record
   nft record

- `winner` : address
   nft record

- `winner_amount` : field
   nft record
  
- `admin_in` : address
   nft record

outputs:

- `NFT` record to winner

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
