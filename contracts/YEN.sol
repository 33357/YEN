// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./libs/ERC20Burnable.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IWETH.sol";

contract YEN is ERC20Burnable {
    event Share(address indexed person, uint256 amount);
    event Get(address indexed person, uint256 amount);
    event Mint(address indexed person, uint256 index);
    event Claim(address indexed person, uint256 amount);
    event Stake(address indexed person, uint256 amount);
    event WithdrawStake(address indexed person, uint256 amount);
    event WithdrawReward(address indexed person, uint256 amount);

    struct Block {
        uint128 persons;
        uint128 mints;
    }

    struct Person {
        uint32[] blockList;
        uint128 blockIndex;
        uint128 stakes;
        uint128 rewards;
        uint128 lastPerStakeRewards;
    }

    struct Sharer {
        uint128 shares;
        uint128 getteds;
    }

    // uint256 public constant halvingBlocks = ((60 * 60 * 24) / 12) * 30;
    uint256 public constant halvingBlocks = ((60 * 60 * 24) / 12) * 1;
    uint256 public lastBlock;
    uint256 public halvingBlock;
    uint256 public blockMints = 100 * 10**18;
    uint256 public mintStartBlock;

    uint256 public stakes = 1;
    uint256 public perStakeRewards;

    uint256 public constant shareTokens = 6800000 * 10**18;
    uint256 public constant getBlocks = ((60 * 60 * 24) / 12) * 100;
    uint256 public immutable shareEndBlock = block.number + ((60 * 60 * 24) / 12) / 24;
    // uint256 public immutable shareEndBlock = block.number + ((60 * 60 * 24) / 12) * 3;
    uint256 public shareEths;
    uint256 public sharePairs;

    uint256 public constant feeAddBlock = (60 * 60) / 12;
    uint256 public transfers;
    uint256 public last100TransferBlock;
    uint256 public lastFeeMul = 1;

    // IWETH public constant weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IWETH public constant weth = IWETH(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    IERC20 public immutable token = IERC20(address(this));
    IUniswapV2Pair public immutable pair =
        IUniswapV2Pair(
            IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(address(weth), address(this))
        );

    mapping(uint256 => Block) public blockMap;
    mapping(address => Person) public personMap;
    mapping(address => Sharer) public sharerMap;

    constructor() ERC20("YEN", "YEN") {}

    /* ================ UTIL FUNCTIONS ================ */

    modifier _checkHalving() {
        unchecked {
            if (block.number >= halvingBlock) {
                blockMints /= 2;
                halvingBlock += halvingBlocks;
            }
        }
        _;
    }

    modifier _checkReward() {
        if (personMap[msg.sender].lastPerStakeRewards != perStakeRewards) {
            personMap[msg.sender].rewards = uint128(getRewards(msg.sender));
            personMap[msg.sender].lastPerStakeRewards = uint128(perStakeRewards);
        }
        _;
    }

    modifier _checkMintStart() {
        require(mintStartBlock != 0, "mint must start!");
        _;
    }

    modifier _checkFeeMul() {
        unchecked {
            if (transfers == 100) {
                lastFeeMul = getFeeMul();
                transfers = 0;
                last100TransferBlock = block.number;
            } else {
                transfers++;
            }
        }
        _;
    }

    function _addPerStakeRewards(uint256 adds) internal {
        unchecked {
            perStakeRewards += adds / stakes;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override _checkFeeMul {
        unchecked {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);

            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

            _balances[sender] = senderBalance - amount;

            uint256 fees;
            if (sender != address(this)) {
                fees = (amount * getFeeMul()) / 1000;
                _balances[address(this)] += fees;
                emit Transfer(sender, address(this), fees);
                uint256 burnFees = fees / 5;
                _burn(address(this), burnFees);
                _addPerStakeRewards(fees - burnFees);
            }

            uint256 recipients = amount - fees;
            _balances[recipient] += recipients;
            emit Transfer(sender, recipient, recipients);

            _afterTokenTransfer(sender, recipient, amount);
        }
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getFeeMul() public view returns (uint256) {
        unchecked {
            uint256 mul = (block.number - last100TransferBlock) / feeAddBlock;
            if (mul > 9) {
                mul = 9;
            }
            mul = 10 - mul;
            return mul < lastFeeMul ? mul : lastFeeMul;
        }
    }

    function gets(address sharer) public view returns (uint256) {
        unchecked {
            uint256 percent = ((block.number - mintStartBlock) * 10000) / getBlocks;
            if (percent > 10000) {
                percent = 10000;
            }
            return
                (((sharePairs * sharerMap[sharer].shares) / shareEths) * percent) / 10000 - sharerMap[sharer].getteds;
        }
    }

    function getMints() public view returns (uint256) {
        unchecked {
            return (block.number - lastBlock) * blockMints;
        }
    }

    function getClaims(address sender) public view returns (uint256) {
        unchecked {
            Person memory person = personMap[sender];
            uint256 claims;
            for (uint256 i = 0; i < person.blockIndex; i++) {
                Block memory _block = blockMap[person.blockList[i]];
                claims += _block.mints / _block.persons;
            }
            return claims;
        }
    }

    function getRewards(address person) public view returns (uint256) {
        unchecked {
            return
                personMap[person].stakes *
                (perStakeRewards - personMap[person].lastPerStakeRewards) +
                personMap[person].rewards;
        }
    }

    function getPersonBlockList(address person) external view returns (uint32[] memory) {
        unchecked {
            uint32[] memory blockList = new uint32[](personMap[person].blockIndex);
            for (uint256 i = 0; i < personMap[person].blockIndex; i++) {
                blockList[i] = personMap[person].blockList[i];
            }
            return blockList;
        }
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function share() external payable {
        unchecked {
            require(block.number < shareEndBlock, "block cannot over shareEndBlock!");
            sharerMap[msg.sender].shares += uint128(msg.value);
            shareEths += msg.value;
            emit Share(msg.sender, msg.value);
        }
    }

    function start() external {
        unchecked {
            require(block.number >= shareEndBlock, "block must over shareEndBlock!");
            require(mintStartBlock == 0, "mint cannot start!");
            weth.deposit{value: shareEths}();
            weth.transfer(address(pair), shareEths);
            _mint(address(pair), shareTokens);
            sharePairs = pair.mint(address(this));
            mintStartBlock = block.number;
            halvingBlock = block.number + halvingBlocks;
            lastBlock = block.number;
        }
    }

    function get() external _checkMintStart {
        unchecked {
            uint256 amount = gets(msg.sender);
            sharerMap[msg.sender].getteds += uint128(amount);
            pair.transfer(msg.sender, amount);
            emit Get(msg.sender, amount);
        }
    }

    function mint() external _checkMintStart _checkHalving {
        unchecked {
            if (block.number != lastBlock) {
                uint256 mints = getMints();
                _mint(address(this), mints);
                blockMap[block.number].mints = uint128(mints / 2);
                lastBlock = block.number;
                _addPerStakeRewards(blockMap[block.number].mints);
            }
            Person storage person = personMap[msg.sender];
            if (person.blockList.length == person.blockIndex) {
                person.blockList.push(uint32(block.number));
            } else {
                person.blockList[person.blockIndex] = uint32(block.number);
            }
            emit Mint(msg.sender, blockMap[block.number].persons);
            blockMap[block.number].persons++;
            person.blockIndex++;
        }
    }

    function claim() external _checkMintStart {
        unchecked {
            Person memory person = personMap[msg.sender];
            require(person.blockList[person.blockIndex - 1] != block.number, "mint claim cannot in sample block!");
            uint256 claims = getClaims(msg.sender);
            personMap[msg.sender].blockIndex = 0;
            token.transfer(msg.sender, claims);
            emit Claim(msg.sender, claims);
        }
    }

    function stake(uint256 amount) external _checkMintStart _checkReward {
        unchecked {
            pair.transferFrom(msg.sender, address(this), amount);
            personMap[msg.sender].stakes += uint128(amount);
            stakes += amount;
            emit Stake(msg.sender, amount);
        }
    }

    function withdrawStake(uint256 amount) public _checkMintStart _checkReward {
        unchecked {
            require(amount <= personMap[msg.sender].stakes, "amount cannot over stakes!");
            personMap[msg.sender].stakes -= uint128(amount);
            stakes -= amount;
            pair.transfer(msg.sender, amount);
            emit WithdrawStake(msg.sender, amount);
        }
    }

    function withdrawReward() public _checkMintStart _checkReward {
        unchecked {
            uint256 rewards = personMap[msg.sender].rewards;
            personMap[msg.sender].rewards = 0;
            token.transfer(msg.sender, rewards);
            emit WithdrawReward(msg.sender, rewards);
        }
    }

    function exit() external {
        withdrawStake(personMap[msg.sender].stakes);
        withdrawReward();
    }
}
