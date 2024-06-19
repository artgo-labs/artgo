#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo withdraw_fee 2000000u64 "$ADDR_3"

# tx hash: at1szd48wtcqmf8n5702f2czl8pxhnv8m7fyye3eea6j0hurkcglyqqf95se8