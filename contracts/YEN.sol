// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract YEN is ERC20 {
    event Mint(address indexed person, uint256 personIndex);
    event Claim(address indexed person, uint256 claimAmount);
    event StakeLP(address indexed person, uint256 stakeAmount);
    event WithdrawLP(address indexed person, uint256 withdrawAmount);
    event WithdrawReward(address indexed person, uint256 rewardAmount);

    struct Block {
        uint128 personAmount;
        uint128 mintAmount;
    }
    struct Person {
        uint32[] blockList;
        uint256 blockIndex;
        uint256 stakeAmount;
        uint256 reward;
        uint256 perStakeRewardStored;
    }

    uint256 public lastBlock;
    uint256 public halvingBlock;
    uint256 public blockMintAmount = 50 * 10**18;
    uint256 public halvingBlockAmount = (60 * 60 * 24 * 30) / 12;

    uint256 public perStakeReward;
    uint256 public stakeBalance;

    IUniswapV2Pair public pair;

    mapping(uint256 => Block) blockMap;
    mapping(address => Person) personMap;

    constructor() ERC20("YEN", "YEN") {
        halvingBlock = block.number + halvingBlockAmount;
        lastBlock = block.number;
        pair = IUniswapV2Pair(
            IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                address(this)
            )
        );
    }

    /* ================ UTIL FUNCTIONS ================ */

    modifier _halvingCheck() {
        unchecked {
            if (block.number >= halvingBlock) {
                blockMintAmount /= 2;
                halvingBlock += halvingBlockAmount;
            }
        }
        _;
    }

    modifier _RewardCheck(address person) {
        if (personMap[person].perStakeRewardStored != perStakeReward) {
            personMap[person].reward = getStakeReward(person);
            personMap[person].perStakeRewardStored = perStakeReward;
        }
        _;
    }

    // function _transfer(
    //     address sender,
    //     address recipient,
    //     uint256 amount
    // ) internal override {
    //     require(sender != address(0), "ERC20: transfer from the zero address");
    //     require(recipient != address(0), "ERC20: transfer to the zero address");

    //     uint256 senderBalance = this._balances[sender];
    //     require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    //     unchecked {
    //         super._balances[sender] = senderBalance - amount;
    //     }
    //     super._balances[recipient] += amount;

    //     emit Transfer(sender, recipient, amount);
    // }

    /* ================ VIEW FUNCTIONS ================ */

    function getMintAmount() public view returns (uint256) {
        unchecked {
            return (block.number - lastBlock) * blockMintAmount;
        }
    }

    function getStakeReward(address person) public view returns (uint256) {
        unchecked {
            return
                personMap[person].stakeAmount *
                (perStakeReward - personMap[person].perStakeRewardStored) +
                personMap[person].reward;
        }
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function mint() external _halvingCheck {
        uint32 blockNumber = uint32(block.number);
        if (blockNumber != lastBlock) {
            blockMap[blockNumber].mintAmount = uint128(getMintAmount());
            lastBlock = blockNumber;
            perStakeReward += blockMap[blockNumber].mintAmount / stakeBalance;
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

    function stakeLP(uint256 stakeAmount) external _RewardCheck(msg.sender) {
        pair.transferFrom(msg.sender, address(this), stakeAmount);
        personMap[msg.sender].stakeAmount += stakeAmount;
        stakeBalance += stakeAmount;
        emit StakeLP(msg.sender, stakeAmount);
    }

    function withdrawLP(uint256 withdrawAmount) public _RewardCheck(msg.sender) {
        require(withdrawAmount <= personMap[msg.sender].stakeAmount, "withdrawAmount cannot over stakeAmount!");
        personMap[msg.sender].stakeAmount -= withdrawAmount;
        stakeBalance -= withdrawAmount;
        pair.transfer(msg.sender, withdrawAmount);
        emit WithdrawLP(msg.sender, withdrawAmount);
    }

    function withdrawReward() public _RewardCheck(msg.sender) {
        uint256 rewardAmount = getStakeReward(msg.sender);
        personMap[msg.sender].perStakeRewardStored = perStakeReward;
        personMap[msg.sender].reward = 0;
        _mint(msg.sender, rewardAmount);
        emit WithdrawReward(msg.sender, rewardAmount);
    }

    function exit() external {
        withdrawLP(personMap[msg.sender].stakeAmount);
        withdrawReward();
    }
}
