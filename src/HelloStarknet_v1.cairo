/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait IHelloStarknet<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: u32);
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> u32;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod HelloStarknet {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        balance: u32,
    }

    #[abi(embed_v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: u32) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> u32 {
            self.balance.read()
        }
    }
}
