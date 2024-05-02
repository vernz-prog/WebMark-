// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CharityChain {
    address public owner;
    mapping(address => uint256) public donations;
    uint256 public totalDonations;

    event Donation(address indexed donor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function donate(address _token, uint256 _amount) external {
        require(_amount > 0, "Invalid donation amount");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        donations[msg.sender] += _amount;
        totalDonations += _amount;

        emit Donation(msg.sender, _amount);
    }

    function withdraw(address _token, uint256 _amount) external onlyOwner {
        require(_amount <= totalDonations, "Not enough balance");

        totalDonations -= _amount;
        require(IERC20(_token).transfer(owner, _amount), "Transfer failed");
    }
}
