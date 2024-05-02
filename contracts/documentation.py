CharityChain Contract Documentation

Functions:
1. donate(address _token, uint256 _amount) - Allows users to donate specified amount of tokens to the contract.
   Parameters:
     - _token: Address of the token to be donated.
     - _amount: Amount of tokens to be donated.
   Modifiers: None
   Events: Donation

2. withdraw(address _token, uint256 _amount) - Allows owner to withdraw specified amount of tokens from the contract.
   Parameters:
     - _token: Address of the token to be withdrawn.
     - _amount: Amount of tokens to be withdrawn.
   Modifiers: onlyOwner
   Events: None

Modifiers:
1. onlyOwner() - Restricts access to functions only to the owner of the contract.

Events:
1. Donation(address indexed donor, uint256 amount) - Emitted when a donation is made. Records the address of the donor and the amount donated.
