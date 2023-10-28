// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract SelfDestruct {

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function destroy() public {
        selfdestruct(owner);
    }
}
