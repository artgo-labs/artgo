#!/bin/bash

snarkos developer execute \
--private-key "$PK_3" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo mint_nft "[1u128,2u128,3u128]" "[1u128,2u128,3u128]" 1024u128

# tx hash: at180vggyceem6l0mqlwym3q0u9e6veums7al9y54exw85zz6597cys7z45eh