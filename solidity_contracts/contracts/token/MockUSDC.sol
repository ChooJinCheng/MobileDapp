// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "USDC") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1 million USDC to the deployer
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
