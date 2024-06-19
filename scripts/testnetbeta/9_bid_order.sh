#!/bin/bash

snarkos developer execute \
--private-key "$PK_3" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo bid_order "{
                                  owner: aleo1hzasxvhu4szvyzz4lcygaksfmyw07r3620hrnr0x9al2cxcxgsps9j000z.private,
                                  microcredits: 1000001u64.private,
                                  _nonce: 729936477663112668165201931682828308151374051060964873944184786774998971227group.public
                                }" 1u128 1000000u64 "$ADDR_2"

# tx hash: at1jvjacvvln3a5zvyqmsvdeqv486g00wv4t6zmt8j3ncc5uaedtcyqejrn62