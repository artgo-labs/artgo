#!/bin/bash

snarkos developer deploy \
--private-key  "$PK_2" \
--query http://hk2.s.filfox.io:60053 \
--priority-fee 1 \
--path ./build/ \
--broadcast http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo

# tx hash: at1wfdh5wcaez0852ctzcytfedzleld8tje4qc5kzzgk0hwefx94y8qat64y7


