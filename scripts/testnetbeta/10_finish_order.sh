#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo finish_order 1u128 "{
                                           owner: aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88.private,
                                           minter: aleo1hzasxvhu4szvyzz4lcygaksfmyw07r3620hrnr0x9al2cxcxgsps9j000z.private,
                                           prompt: [
                                             1u128.private,
                                             2u128.private,
                                             3u128.private
                                           ],
                                           nonce: 1024u128.private,
                                           uri: [
                                             1u128.private,
                                             2u128.private,
                                             3u128.private
                                           ],
                                           _nonce: 7529470214970542794995575486317044115451930383444336746804318570518391568129group.public
                                         }" "$ADDR_2" 1000000u64 "$ADDR_3" 1000000u64

# tx hash: at1z4pazjevq3n8eyjre7vhk2x24zr9wuutadp5gza7tz9ny2c9rv8q7f6caw