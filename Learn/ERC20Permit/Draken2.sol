// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Draken2 is ERC20Permit{
    constructor() ERC20("Draken2", "DAK2") ERC20Permit("PermitToken"){
        _mint(msg.sender, 100000 * 10 ** decimals());
    }
}