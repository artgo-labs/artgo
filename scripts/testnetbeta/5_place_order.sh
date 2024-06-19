#!/bin/bash

snarkos developer execute \
--private-key "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo place_order 1u128 "{
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
                                          _nonce: 2989415603474923173369309385246717853453015809584256099223374847065135608103group.public
                                        }" 1u8 1000000u64 666666u32 "$ADDR_2"

# tx hash: at18nntasjd2jyjzkjr56ynjd6faz5ntmngf84u0xtulqk55lftggyshl68we