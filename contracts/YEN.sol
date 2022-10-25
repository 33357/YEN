// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./libs/ERC20.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IWETH.sol";

contract YEN is ERC20 {
    event Mint(address indexed person, uint256 personIndex);
    event Claim(address indexed person, uint256 claimAmount);
    event Stake(address indexed person, uint256 stakeAmount);
    event WithdrawStake(address indexed person, uint256 withdrawAmount);
    event WithdrawReward(address indexed person, uint256 rewardAmount);

    struct Block {
        uint128 personAmount;
        uint128 mintAmount;
    }
    struct Person {
        uint32[] blockList;
        uint256 blockIndex;
        uint256 stakeAmount;
        uint256 rewardStored;
        uint256 lastPerStakeReward;
    }
    struct Buyer {
        uint256 buyEthAmount;
        uint256 getAmount;
    }

    uint256 public constant halvingBlockAmount = (60 * 60 * 24 * 30) / 12;
    uint256 public lastBlock;
    uint256 public halvingBlock;
    uint256 public blockMintAmount = 100 * 10**18;

    uint256 public perStakeReward;
    uint256 public stakeBalance;

    uint256 public constant sellBlockAmount = (60 * 60 * 24 * 3) / 12;
    uint256 public constant sellAmount = 6800000 * 10**18;
    uint256 public constant getMintBlockAmount = (60 * 60 * 24 * 100) / 12;
    uint256 public immutable sellEndBlock = block.number + sellBlockAmount;
    uint256 public sellETHAmount;
    uint256 public sellPairAmount;
    uint256 public mintStartBlock;

    uint256 public constant fee = 1;
    uint256 public constant feeBase = 1000;

    IWETH public constant weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public immutable token = IERC20(address(this));
    IUniswapV2Pair public immutable pair =
        IUniswapV2Pair(
            IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(address(weth), address(this))
        );

    mapping(uint256 => Block) blockMap;
    mapping(address => Person) personMap;
    mapping(address => Buyer) buyerMap;

    constructor() ERC20("YEN", "YEN") {}

    /* ================ UTIL FUNCTIONS ================ */

    modifier _checkHalving() {
        unchecked {
            if (block.number >= halvingBlock) {
                blockMintAmount /= 2;
                halvingBlock += halvingBlockAmount;
            }
        }
        _;
    }

    modifier _checkReward(address person) {
        if (personMap[person].lastPerStakeReward != perStakeReward) {
            personMap[person].rewardStored = getStakeReward(person);
            personMap[person].lastPerStakeReward = perStakeReward;
        }
        _;
    }

    modifier _checkMintStart() {
        require(mintStartBlock != 0, "mint must start!");
        _;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint256 feeAmount = (amount * fee) / feeBase;
        _balances[address(this)] += feeAmount;
        perStakeReward += feeAmount / stakeBalance;
        uint256 getAmount = amount - feeAmount;
        _balances[recipient] += getAmount;

        emit Transfer(sender, address(this), feeAmount);
        emit Transfer(sender, recipient, getAmount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getSellAmount(address buyer) public view returns (uint256) {
        unchecked {
            uint256 percent = ((block.number - mintStartBlock) * 100) / getMintBlockAmount;
            if (percent > 100) {
                percent = 100;
            }
            return
                (((sellPairAmount * buyerMap[buyer].buyEthAmount) / sellETHAmount) * percent) /
                100 -
                buyerMap[buyer].getAmount;
        }
    }

    function getMintAmount() public view returns (uint256) {
        unchecked {
            return (block.number - lastBlock) * blockMintAmount;
        }
    }

    function getStakeReward(address person) public view returns (uint256) {
        unchecked {
            return
                personMap[person].stakeAmount *
                (perStakeReward - personMap[person].lastPerStakeReward) +
                personMap[person].rewardStored;
        }
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function preSell() external payable {
        require(block.number < sellEndBlock, "block cannot over sellEndBlock!");
        buyerMap[msg.sender].buyEthAmount += msg.value;
        sellETHAmount += msg.value;
    }

    function endSell() external {
        require(block.number >= sellEndBlock, "block must over sellEndBlock!");
        require(mintStartBlock == 0, "mint cannot start!");
        weth.deposit{value: sellETHAmount}();
        weth.transfer(address(pair), sellETHAmount);
        _mint(address(pair), sellAmount);
        sellPairAmount = pair.mint(address(this));
        mintStartBlock = block.number;
        halvingBlock = block.number + halvingBlockAmount;
        lastBlock = block.number;
    }

    function getSell(uint256 getAmount) external _checkMintStart {
        uint256 maxGetAmount = getSellAmount(msg.sender);
        require(getAmount <= maxGetAmount, "cannot over maxGetAmount!");
        buyerMap[msg.sender].getAmount += getAmount;
        pair.transfer(msg.sender, getAmount);
    }

    function mint() external _checkMintStart _checkHalving {
        uint32 blockNumber = uint32(block.number);
        if (blockNumber != lastBlock) {
            uint256 mintAmount = getMintAmount();
            _mint(address(this), mintAmount);
            blockMap[blockNumber].mintAmount = uint128(mintAmount / 2);
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

    function claim() external _checkMintStart {
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
        token.transfer(msg.sender, claimAmount);
        emit Claim(msg.sender, claimAmount);
    }

    function stake(uint256 stakeAmount) external _checkMintStart _checkReward(msg.sender) {
        pair.transferFrom(msg.sender, address(this), stakeAmount);
        personMap[msg.sender].stakeAmount += stakeAmount;
        stakeBalance += stakeAmount;
        emit Stake(msg.sender, stakeAmount);
    }

    function withdrawStake(uint256 withdrawAmount) public _checkMintStart _checkReward(msg.sender) {
        require(withdrawAmount <= personMap[msg.sender].stakeAmount, "withdrawAmount cannot over stakeAmount!");
        personMap[msg.sender].stakeAmount -= withdrawAmount;
        stakeBalance -= withdrawAmount;
        pair.transfer(msg.sender, withdrawAmount);
        emit WithdrawStake(msg.sender, withdrawAmount);
    }

    function withdrawReward() public _checkMintStart _checkReward(msg.sender) {
        uint256 rewardAmount = personMap[msg.sender].rewardStored;
        personMap[msg.sender].rewardStored = 0;
        token.transfer(msg.sender, rewardAmount);
        emit WithdrawReward(msg.sender, rewardAmount);
    }

    function exit() external {
        withdrawStake(personMap[msg.sender].stakeAmount);
        withdrawReward();
    }
}
