import credits.aleo;
program artgo_aigc_v0_1.aleo;


struct NftHash:
    minter as address;
    prompt as [u128; 3u32];
    nonce as u128;

struct NftInfo:
    holder as address;
    minter as address;
    hash as field;
    uri as [u128; 3u32];

struct Order:
    holder as address;
    nft_id as u128;
    order_type as u8;
    amount as u64;
    status as u8;
    deadline as u32;

struct Bid:
    bidder as address;
    nft_id as u128;
    amount as u64;

record Nft:
    owner as address.private;
    minter as address.private;
    prompt as [u128; 3u32].private;
    nonce as u128.private;
    uri as [u128; 3u32].private;

struct Setting:
    admin as address;
    operator as address;
    fee as u64;


mapping nfts:
	key as u128.public;
	value as NftInfo.public;


mapping next_nft_id:
	key as boolean.public;
	value as u128.public;


mapping orders:
	key as u128.public;
	value as Order.public;


mapping bids:
	key as u128.public;
	value as Bid.public;


mapping settings:
	key as boolean.public;
	value as Setting.public;


function init:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    assert.eq self.caller aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88;
    async init r0 r1 r2 into r3;
    output r3 as artgo_aigc_v0_1.aleo/init.future;

finalize init:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    contains settings[true] into r3;
    assert.eq r3 false;
    cast r0 r1 r2 into r4 as Setting;
    set r4 into settings[true];
    set 1u128 into next_nft_id[true];




function mint_nft:
    input r0 as [u128; 3u32].private;
    input r1 as [u128; 3u32].public;
    input r2 as u128.public;
    cast self.caller r0 r2 into r3 as NftHash;
    hash.bhp256 r3 into r4 as field;
    cast self.caller self.caller r0 r2 r1 into r5 as Nft.record;
    async mint_nft self.caller r4 r1 into r6;
    output r5 as Nft.record;
    output r6 as artgo_aigc_v0_1.aleo/mint_nft.future;

finalize mint_nft:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as [u128; 3u32].public;
    get next_nft_id[true] into r3;
    add r3 1u128 into r4;
    set r4 into next_nft_id[true];
    cast r0 r0 r1 r2 into r5 as NftInfo;
    set r5 into nfts[r3];




function transfer_private_nft:
    input r0 as u128.private;
    input r1 as Nft.record;
    input r2 as address.private;
    cast r1.minter r1.prompt r1.nonce into r3 as NftHash;
    hash.bhp256 r3 into r4 as field;
    cast r2 r1.minter r1.prompt r1.nonce r1.uri into r5 as Nft.record;
    async transfer_private_nft r0 r4 r1.uri r2 into r6;
    output r5 as Nft.record;
    output r6 as artgo_aigc_v0_1.aleo/transfer_private_nft.future;

finalize transfer_private_nft:
    input r0 as u128.public;
    input r1 as field.public;
    input r2 as [u128; 3u32].public;
    input r3 as address.public;
    get nfts[r0] into r4;
    assert.eq r4.hash r1;
    assert.eq r4.uri r2;
    cast r3 r4.minter r4.hash r4.uri into r5 as NftInfo;
    set r5 into nfts[r0];




function place_order:
    input r0 as u128.public;
    input r1 as Nft.record;
    input r2 as u8.public;
    input r3 as u64.public;
    input r4 as u32.public;
    input r5 as address.public;
    assert.eq r2 1u8;
    cast r1.minter r1.prompt r1.nonce into r6 as NftHash;
    hash.bhp256 r6 into r7 as field;
    cast r5 r1.minter r1.prompt r1.nonce r1.uri into r8 as Nft.record;
    async place_order r5 r0 r7 r1.uri self.caller r2 r3 r4 into r9;
    output r8 as Nft.record;
    output r9 as artgo_aigc_v0_1.aleo/place_order.future;

finalize place_order:
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as field.public;
    input r3 as [u128; 3u32].public;
    input r4 as address.public;
    input r5 as u8.public;
    input r6 as u64.public;
    input r7 as u32.public;
    gt r7 block.height into r8;
    assert.eq r8 true;
    get settings[true] into r9;
    assert.eq r0 r9.operator;
    gte r6 r9.fee into r10;
    assert.eq r10 true;
    get nfts[r1] into r11;
    assert.eq r11.hash r2;
    assert.eq r11.uri r3;
    contains orders[r1] into r12;
    assert.eq r12 false;
    cast r4 r1 r5 r6 1u8 r7 into r13 as Order;
    set r13 into orders[r1];




function update_order:
    input r0 as u128.public;
    input r1 as u64.public;
    async update_order self.caller r0 r1 into r2;
    output r2 as artgo_aigc_v0_1.aleo/update_order.future;

finalize update_order:
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as u64.public;
    get settings[true] into r3;
    gte r2 r3.fee into r4;
    assert.eq r4 true;
    get orders[r1] into r5;
    assert.eq r5.status 1u8;
    assert.eq r0 r5.holder;
    cast r5.holder r5.nft_id r5.order_type r2 r5.status r5.deadline into r6 as Order;
    set r6 into orders[r1];

