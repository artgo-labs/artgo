// The 'credits' program
program credits.aleo {
    mapping account: address => u64;

    record credits {
        private owner: address;
        private microcredits: u64;
    }
    
    // The `transfer_public` function sends the specified amount
    // from the sender's `account` to the receiver's `account`.
    transition transfer_public(public to: address, public amount: u64) {
        return;
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

    transition transfer_private_to_public(private input: credits, public to: address, public amount: u64) -> (credits) {
        return input;
    }
}
