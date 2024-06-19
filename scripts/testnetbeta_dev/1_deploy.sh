#!/bin/bash

snarkos developer deploy \
--private-key  "$PK_1" \
--query http://hk2.s.filfox.io:60052 \
--priority-fee 1 \
--path ./build/ \
--broadcast http://hk2.s.filfox.io:60052/testnet/transaction/broadcast \
--network 1 \
artgo_aigc_v0_1.aleo

# tx hash: at1ae2qgpqcncz365fu2kme8jvcm9g4hf6pqxfk0fr5d6pwek0czcpshlhmge


