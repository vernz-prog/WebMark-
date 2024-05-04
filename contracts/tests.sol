// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CharityChain is Ownable {
    struct Donation {
        address donor;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint256) private _balances;
    mapping(address => Donation[]) private _donations;

    event DonationReceived(address indexed donor, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event DonationClaimed(address indexed recipient, uint256 amount);

    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    constructor() Ownable(msg.sender) payable {} // Добавляем вызов конструктора родительского контракта с текущим адресом в качестве владельца

    function donate(address payable _recipient) external payable onlyValidAddress(_recipient) {
        require(msg.value > 0, "Invalid donation amount");

        _balances[_recipient] += msg.value;
        _donations[_recipient].push(Donation(msg.sender, msg.value, block.timestamp));

        emit DonationReceived(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= address(this).balance, "Invalid withdrawal amount");
        
        payable(owner()).transfer(_amount);

        emit FundsWithdrawn(owner(), _amount);
    }

    function getBalance(address _address) external view returns (uint256) {
        return _balances[_address];
    }

    function claimDonations() external onlyValidAddress(msg.sender) {
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "No donations to claim");

        _balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit DonationClaimed(msg.sender, amount);
    }

    function getDonationCount(address _address) external view returns (uint256) {
        return _donations[_address].length;
    }

    function getDonationDetails(address _address, uint256 _index) external view returns (address, uint256, uint256) {
        require(_index < _donations[_address].length, "Invalid donation index");

        Donation memory donation = _donations[_address][_index];
        return (donation.donor, donation.amount, donation.timestamp);
    }
}
