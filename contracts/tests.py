// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "chai";

import { CharityChain } from "../contracts/CharityChain.sol";

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract CharityChainTest {
    using SafeMath for uint256;
    using Address for address payable;

    CharityChain public charityChain;
    TestToken public testToken;

    address public owner;
    address public donor;

    uint256 public initialBalance;

    beforeAll(async () => {
        owner = await ethers.getSigner(0);
        donor = await ethers.getSigner(1);

        testToken = await ethers.getContractFactory("TestToken").deploy();
        charityChain = await ethers.getContractFactory("CharityChain").deploy();

        initialBalance = await testToken.balanceOf(donor.address);
        await testToken.approve(charityChain.address, 1000);
    });

    it("should donate to CharityChain", async () => {
        await charityChain.donate(testToken.address, 100);
        const donation = await charityChain.donations(donor.address);
        expect(donation).to.equal(100);
    });

    it("should withdraw from CharityChain", async () => {
        await charityChain.withdraw(testToken.address, 50);
        const totalDonations = await charityChain.totalDonations();
        expect(totalDonations).to.equal(50);

        const balance = await testToken.balanceOf(owner.address);
        expect(balance).to.equal(50);
    });

    it("should revert if withdrawing more than total donations", async () => {
        await expect(charityChain.withdraw(testToken.address, 100)).to.be.revertedWith("Not enough balance");
    });
}

