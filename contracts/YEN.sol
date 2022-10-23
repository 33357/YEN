// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YEN is ERC20 {
    event Mint(address indexed person, uint256 personIndex);
    event Claim(address indexed person, uint256 claimAmount);

    struct Block {
        uint128 personAmount;
        uint128 mintAmount;
    }
    struct Person {
        uint32[] blockList;
        uint256 blockIndex;
    }

    uint256 public lastBlock;
    uint256 public halvingBlock;
    uint256 public blockMintAmount = 50 * 10**18;
    uint256 public halvingBlockAmount = (60 * 60 * 24 * 30) / 12;

    mapping(uint256 => Block) blockMap;
    mapping(address => Person) personMap;

    constructor() ERC20("YEN", "YEN") {
        halvingBlock = block.number + halvingBlockAmount;
        lastBlock = block.number;
    }

    function getMintAmount() public view returns (uint256) {
        unchecked {
            return (block.number - lastBlock) * blockMintAmount;
        }
    }

    modifier _halvingCheck() {
        unchecked {
            if (block.number >= halvingBlock) {
                blockMintAmount /= 2;
                halvingBlock += halvingBlockAmount;
            }
        }
        _;
    }

    function mint() external _halvingCheck {
        uint32 blockNumber = uint32(block.number);
        if (blockNumber != lastBlock) {
            blockMap[blockNumber].mintAmount = uint128(getMintAmount());
            lastBlock = blockNumber;
        }
        Person storage person = personMap[msg.sender];
        if (person.blockList.length == person.blockIndex) {
            person.blockList.push(blockNumber);
        } else {
            person.blockList[person.blockIndex] = blockNumber;
        }
        emit Mint(msg.sender, blockMap[blockNumber].personAmount);
        unchecked {
            blockMap[blockNumber].personAmount++;
            person.blockIndex++;
        }
    }

    function claim() external {
        Person memory person = personMap[msg.sender];
        require(person.blockList[person.blockIndex - 1] != block.number, "mint claim cannot in sample block!");
        uint256 claimAmount;
        unchecked {
            for (uint256 i = 0; i < person.blockIndex; i++) {
                Block memory _block = blockMap[person.blockList[i]];
                claimAmount += _block.mintAmount / _block.personAmount;
            }
        }
        personMap[msg.sender].blockIndex = 0;
        _mint(msg.sender, claimAmount);
        emit Claim(msg.sender, claimAmount);
    }
}
