// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RialToken is ERC20 {
    address public owner;

    // modifier to check if the caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(
       string memory name,
       string memory symbol,
       uint256 initialSupply
   ) ERC20(name, symbol) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
   }

   function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}