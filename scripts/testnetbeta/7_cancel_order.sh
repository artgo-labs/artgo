#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo cancel_order "{
                                     owner: aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88.private,
                                     microcredits: 2000000u64.private,
                                     _nonce: 304019483221054690564021711033944453702373355697032097780839821942351474209group.public
                                   }" 1000000u64 1u128 "$ADDR_2"

# tx hash: at1wns2zf79jav5wdstmgl76gx59yr0k3sldmwnynjn0dyc6mq63qqqcnr48z