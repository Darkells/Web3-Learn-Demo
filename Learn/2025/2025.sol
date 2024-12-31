// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NewYear2025 {
    string public message;

    constructor() {
        message = "Happy New Year 2025!";
    }

    function getMessage() public view returns (string memory) {
        return message;
    }
}