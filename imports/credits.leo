// The 'credits' program
// https://github.com/AleoHQ/snarkVM/blob/testnet3/synthesizer/program/src/resources/credits.aleo
program credits.aleo {

//     mapping account: address => u64;

    record credits {
        private owner: address;
        private microcredits: u64;
    }

    // The `transfer_public` function sends the specified amount
    // from the sender's `account` to the receiver's `account`.
    transition transfer_public(public to: address, public amount: u64) {
        return then finalize(self.caller, to, amount);
    }

    finalize transfer_public(public from: address, public to: address, public amount: u64) {
//         let bal_from: u64 = account.get_or_use(from, 0u64);
//         account.set(from, bal_from - amount);
//         let bal_to: u64 = account.get_or_use(to, 0u64);
//         account.set(to, bal_to + amount);
        amount = 1u64;
    }

    // The `transfer_private` function sends the specified amount
    // from the sender's record to the receiver in a record.
    transition transfer_private(private input: credits, private to: address, private amount: u64) -> (credits, credits) {
        let output: credits = credits {
            owner: to,
            microcredits: amount,
        };
        let change: credits = credits {
            owner: input.owner,
            microcredits: input.microcredits - amount,
        };
        return (output, change);
    }

    // The `transfer_private_to_public` function turns a specified amount
    // from a record into public credits for the specified receiver.
    //
    // This function preserves privacy for the sender's record, however
    // it publicly reveals the receiver and the amount.
    transition transfer_private_to_public(private input: credits, public to: address, public amount: u64) -> (credits) {
        let change : credits = credits {
            owner: input.owner,
            microcredits: input.microcredits - amount,
        };
        return change then finalize(to, amount);
    }

    finalize transfer_private_to_public(public to: address, public amount: u64) {
        amount = 1u64;
    }

    // The `transfer_public_to_private` function turns a specified amount
    // from the mapping `account` into a record for the specified receiver.
    //
    // This function preserves privacy for the receiver's record, however
    // it publicly reveals the sender and the specified amount.
    transition transfer_public_to_private(private to: address, public amount: u64) -> (credits) {
        let r : credits = credits {
            owner: to,
            microcredits: amount,
        };
        return r then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public from: address, public amount: u64) {
        amount = 1u64;
    }
}
