/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
use starknet::ContractAddress;
#[starknet::interface]
pub trait IHelloStarknet_v2<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: u32);

    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> u32;

    /// add new owner
    fn add_new_owner(ref self: TContractState, new_owner: ContractAddress);

    fn increase_balance_by_one(ref self: TContractState);

    fn get_current_owner(self: @TContractState) -> ContractAddress;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod HelloStarknet_v2 {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    #[storage]
    struct Storage {
        balance: u32,
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _owner: ContractAddress) {
        self.owner.write(_owner);
    }

    #[abi(embed_v0)]
    impl HelloStarknet_v2Impl of super::IHelloStarknet_v2<ContractState> {
        fn increase_balance(ref self: ContractState, amount: u32) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> u32 {
            self.balance.read()
        }

        fn add_new_owner(ref self: ContractState, new_owner: ContractAddress) {
            // validation to ensure only owner can invoke this function
            self.only_owner();
            // assert that new owner is not the current owner
            assert(self.get_current_owner() != new_owner, 'same Owner');
            self.owner.write(new_owner);
        }

        fn increase_balance_by_one(ref self: ContractState) {
            let current_balance = self.get_balance();
            self.balance.write(current_balance + 1);
        }

        fn get_current_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn only_owner(self: @ContractState) {
            // add fn caller
            let caller: ContractAddress = get_caller_address();

            // get owner of heelostarknet contract
            let current_owner: ContractAddress = self.owner.read();

            // asertion logic
            assert(caller == current_owner, 'caller is not the owner');
        }
    }
}
