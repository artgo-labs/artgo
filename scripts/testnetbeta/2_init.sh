#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo init aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88 aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88 1000000u64

# admin: aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88
# operator: aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88
# fee: 1000000u64

# tx hash: at1c50n4q4vj284vqe73uqwk59g3v5yk3ad88dctgzhg3tq0l3rpyzsjrhd42

