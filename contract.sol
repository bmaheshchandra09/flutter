//0xd9145CCE52D386f254917e481eB44e9943F39138

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NonaToken is ERC20{

    constructor(uint256 initialSupply)public ERC20("Gold","GD"){
        _mint(msg.sender,initialSupply);
    }

}