#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo update_order 1u128 1111111u64

# tx hash: at1fzdvh3k07wcnhj9e8zw56gf2mzs0j2uewhndmnv5ls30h3aygqfqqenlzp