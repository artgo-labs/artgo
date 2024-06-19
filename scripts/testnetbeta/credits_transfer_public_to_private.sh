#!/bin/bash

snarkos developer execute \
--private-key "$PK_3" \
--query http://hk2.s.filfox.io:60053 \
-b http://hk2.s.filfox.io:60053/testnet/transaction/broadcast \
--network 1 \
credits.aleo transfer_public_to_private "$ADDR_3" 1000001u64

# tx hash: at1t2pd2qy7pkrhp6kcm7ae8v6494e4yapsv4ra43mukwgs492ggu8qy56acn