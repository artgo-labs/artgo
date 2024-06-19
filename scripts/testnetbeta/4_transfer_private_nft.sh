#!/bin/bash

snarkos developer execute \
--private-key "$PK_3" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo transfer_private_nft 1u128 "{
                                             owner: aleo1hzasxvhu4szvyzz4lcygaksfmyw07r3620hrnr0x9al2cxcxgsps9j000z.private,
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
                                             _nonce: 1054366591874380884378592957424609918463691489109128774895278480299851146994group.public
                                           }" "$ADDR_2"

# tx hash: at1g4aseyp0t25luyk3k4kjrdhr34e3vy3arfzcrwge24ucw30a3sxsxnf0xr