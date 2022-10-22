// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YEN is ERC20 {
    struct PerMint {
        uint256 amount;
        uint256 mint;
    }

    struct PerBlock {
        uint32[] list;
        uint256 index;
    }

    uint256 public lastBlock;
    uint256 public blockMint = 10**18;

    mapping(uint256 => PerMint) perMintMap;
    mapping(address => PerBlock) perBlockMap;

    constructor() ERC20("YEN", "YEN") {}

    function getMint() public view returns (uint256) {
        return (block.timestamp - lastBlock) * blockMint;
    }

    function mint() external {
        uint32 blockNumber = uint32(block.number);
        if (blockNumber != lastBlock) {
            perMintMap[blockNumber].mint = getMint();
            lastBlock = blockNumber;
        }
        PerBlock storage perBlock = perBlockMap[msg.sender];
        if (perBlock.list.length == perBlock.index) {
            perBlock.list.push(blockNumber);
        } else {
            perBlock.list[perBlock.index] = blockNumber;
        }
        unchecked {
            perMintMap[blockNumber].amount++;
            perBlock.index++;
        }
    }

    function claim() external {
        PerBlock memory perBlock = perBlockMap[msg.sender];
        require(perBlock.list[perBlock.index - 1] != block.number, "sample block!");
        uint256 amount;
        unchecked {
            for (uint256 i = 0; i < perBlock.index; i++) {
                amount += perMintMap[perBlock.list[i]].mint / perMintMap[perBlock.list[i]].amount;
            }
        }
        perBlockMap[msg.sender].index = 0;
        _mint(msg.sender, amount);
    }
}
