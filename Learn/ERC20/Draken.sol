// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Draken is ERC20 {
    constructor() ERC20("Draken", "DAK") {
        _mint(msg.sender, 100000 * 10 ** 18);
    }
}

