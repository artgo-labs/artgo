#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo handle_cancel_order 1u128 "{
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
                                                  _nonce: 3838609092003179247963730760238467394970413961955491934817716891059540276139group.public
                                                }" "$ADDR_2"

# tx hash: at1l4gyhtjcf7774f7t98lem9pnz0rnutah09r8k4wg3wfgdup3kspspamkh6