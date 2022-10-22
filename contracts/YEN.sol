// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YEN is ERC20 {
    event Mint(address indexed person, uint256 index);
    event Claim(address indexed person, uint256 amount);

    struct Block {
        uint128 personAmount;
        uint128 mintAmount;
    }
    struct Person {
        uint32[] blockList;
        uint256 blockIndex;
    }

    uint128 public lastBlock;
    uint128 public perBlockMintAmount = 10**18;

    mapping(uint256 => Block) blockMap;
    mapping(address => Person) personMap;

    constructor() ERC20("YEN", "YEN") {}

    function getMintAmount() public view returns (uint128) {
        return uint128((block.number - lastBlock) * perBlockMintAmount);
    }

    function mint() external {
        uint32 blockNumber = uint32(block.number);
        if (blockNumber != lastBlock) {
            blockMap[blockNumber].mintAmount = getMintAmount();
            lastBlock = blockNumber;
        }
        Person storage person = personMap[msg.sender];
        if (person.blockList.length == person.blockIndex) {
            person.blockList.push(blockNumber);
        } else {
            person.blockList[person.blockIndex] = blockNumber;
        }
        emit Mint(msg.sender, person.blockIndex);
        unchecked {
            blockMap[blockNumber].personAmount++;
            person.blockIndex++;
        }
    }

    function claim() external {
        Person memory person = personMap[msg.sender];
        require(person.blockList[person.blockIndex - 1] != block.number, "mint claim cannot in sample block!");
        uint256 amount;
        unchecked {
            for (uint256 i = 0; i < person.blockIndex; i++) {
                Block memory _block = blockMap[person.blockList[i]];
                amount += _block.mintAmount / _block.personAmount;
            }
        }
        personMap[msg.sender].blockIndex = 0;
        _mint(msg.sender, amount);
        emit Claim(msg.sender, amount);
    }
}
