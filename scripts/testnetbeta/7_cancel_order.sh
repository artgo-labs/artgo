#!/bin/bash

misc-toolkit execute \
--private-key APrivateKey1zkpGze7wAkvb3XQdNmnFyN9NSC1NiGGMU3LoRw9yH17Yb1J \
--endpoint http://hk2.s.filfox.io:60050 \
-b \
artgo_aigc_v1_6.aleo cancel_order "{
                                     owner: aleo1rh4whtqef93v2et8j9lujxr67l64fz9ctgn035lwqmp9h6wdf5psa4uu88.private,
                                     microcredits: 1000000u64.private,
                                     _nonce: 8381326883085761753591694771733808260640201675470744349415443474755472590644group.public
                                   }" 1000000u64 2u128 aleo1tjw6lw3zgk4q4vgmwctzerr9tgyay8v0rn3asp7rwujtcj0lwsrq4mr9ng