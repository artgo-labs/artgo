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
        return then finalize(to, amount);
    }

    finalize transfer_public(to: address, amount: u64){
        return;
    }

    transition transfer_private_to_public(private input: credits, public to: address, public amount: u64) -> (credits) {
        return input then finalize(to, amount);
    }

    finalize transfer_private_to_public(to: address, amount: u64) {
        Mapping::set(account, to, amount);
    }

}
