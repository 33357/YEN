// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StepToken is ERC20 {
    uint256 public lastBlock;
    uint256 public tokenPerStep = 10**18;

    constructor() ERC20("StepToken", "ST") {}

    event Run(address runner, uint256 stepToken);

    function getStep() public view returns (uint256) {
        return block.timestamp - lastBlock;
    }

    function getStepToken() public view returns (uint256) {
        return tokenPerStep * getStep();
    }

    function run() external {
        uint256 stepToken = getStepToken();
        _mint(msg.sender, stepToken);
        emit Run(msg.sender, stepToken);
    }
}
