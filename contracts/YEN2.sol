// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;
// import "./libs/ERC20.sol";
// import "./interfaces/IUniswapFactory.sol";
// import "./interfaces/IUniswapV2Pair.sol";
// import "./interfaces/IWETH.sol";

// contract YEN2 is ERC20 {
//     event Share(address indexed person, uint256 amount);
//     event Get(address indexed person, uint256 amount);
//     event Mint(address indexed person, uint256 index);
//     event Claim(address indexed person, uint256 amount);
//     event Stake(address indexed person, uint256 amount);
//     event WithdrawStake(address indexed person, uint256 amount);
//     event WithdrawReward(address indexed person, uint256 amount);

//     struct Block {
//         uint64 miners;
//         uint64 transfers;
//         uint128 minted;
//     }

//     struct Person {
//         uint32[] blockList;
//         uint128 blockIndex;
//         uint128 stake;
//         uint128 reward;
//         uint128 lastPerStakeReward;
//     }

//     struct Sharer {
//         uint128 share;
//         uint128 get;
//     }

//     uint256 public constant halvingBlockAmount = ((60 * 60 * 24) / 12) * 30;
//     uint256 public lastBlock;
//     uint256 public halvingBlock;
//     uint256 public blockMintAmount = 100 * 10**18;
//     uint256 public mintStartBlock;

//     uint256 public stakeAmount = 1;
//     uint256 public perStakeRewardAmount;

//     uint256 public constant shareBlockAmount = ((60 * 60 * 24) / 12) * 3;
//     uint256 public constant shareTokenAmount = 6800000 * 10**18;
//     uint256 public constant getBlockAmount = ((60 * 60 * 24) / 12) * 100;
//     uint256 public immutable shareEndBlock = block.number + shareBlockAmount;
//     uint256 public shareEthAmount;
//     uint256 public sharePairAmount;

//     uint256 public constant stakerFee = 3;
//     uint256 public constant funderFee = 4;
//     uint256 public constant burnFee = 3;
//     address public funder = msg.sender;

//     uint256 public constant hourBlockAmount = (60 * 60) / 12;

//     IWETH public constant weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
//     IERC20 public immutable token = IERC20(address(this));
//     IUniswapV2Pair public immutable pair =
//         IUniswapV2Pair(
//             IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(address(weth), address(this))
//         );

//     mapping(uint256 => Block) public blockMap;
//     mapping(address => Person) public personMap;
//     mapping(address => Sharer) public sharerMap;

//     constructor() ERC20("YEN", "YEN") {}

//     /* ================ UTIL FUNCTIONS ================ */

//     modifier _checkHalving() {
//         unchecked {
//             if (block.number >= halvingBlock) {
//                 blockMintAmount /= 2;
//                 halvingBlock += halvingBlockAmount;
//             }
//         }
//         _;
//     }

//     modifier _checkReward() {
//         if (personMap[msg.sender].lastPerStakeRewardAmount != perStakeRewardAmount) {
//             personMap[msg.sender].rewardAmount = uint128(getRewardAmount(msg.sender));
//             personMap[msg.sender].lastPerStakeRewardAmount = uint128(perStakeRewardAmount);
//         }
//         _;
//     }

//     modifier _checkMintStart() {
//         require(mintStartBlock != 0, "mint must start!");
//         _;
//     }

//     function _addPerStakeRewardAmount(uint256 addAmount) internal {
//         perStakeRewardAmount += addAmount / stakeAmount;
//     }

//     function _transfer(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) internal override {
//         require(sender != address(0), "ERC20: transfer from the zero address");
//         require(recipient != address(0), "ERC20: transfer to the zero address");

//         _beforeTokenTransfer(sender, recipient, amount);

//         uint256 senderBalance = _balances[sender];
//         require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
//         unchecked {
//             _balances[sender] = senderBalance - amount;
//         }

//         uint256 stakerFeeAmount;
//         uint256 funderFeeAmount;
//         if (sender != address(this)) {
//             stakerFeeAmount = (amount * stakerFee) / 10000;
//             funderFeeAmount = (amount * funderFee) / 10000;
//             _balances[address(this)] += stakerFeeAmount;
//             _addPerStakeRewardAmount(stakerFeeAmount);
//             emit Transfer(sender, address(this), stakerFeeAmount);
//             _balances[funder] += funderFeeAmount;
//             emit Transfer(sender, funder, funderFeeAmount);
//         }
//         uint256 getAmount = amount - funderFeeAmount - stakerFeeAmount;
//         _balances[recipient] += getAmount;
//         emit Transfer(sender, recipient, getAmount);

//         _afterTokenTransfer(sender, recipient, amount);
//     }

//     /* ================ VIEW FUNCTIONS ================ */

//     function maxGetAmount(address sharer) public view returns (uint256) {
//         unchecked {
//             uint256 percent = ((block.number - mintStartBlock) * 100) / getBlockAmount;
//             if (percent > 100) {
//                 percent = 100;
//             }
//             return
//                 (((sharePairAmount * sharerMap[sharer].shareAmount) / shareEthAmount) * percent) /
//                 100 -
//                 sharerMap[sharer].getAmount;
//         }
//     }

//     function getMintAmount() public view returns (uint256) {
//         unchecked {
//             return (block.number - lastBlock) * blockMintAmount;
//         }
//     }

//     function getRewardAmount(address person) public view returns (uint256) {
//         unchecked {
//             return
//                 personMap[person].stakeAmount *
//                 (perStakeRewardAmount - personMap[person].lastPerStakeRewardAmount) +
//                 personMap[person].rewardAmount;
//         }
//     }

//     function getPersonBlockList(address person) external view returns (uint32[] memory) {
//         uint32[] memory blockList = new uint32[](personMap[person].blockIndex);
//         for (uint256 i = 0; i < personMap[person].blockIndex; i++) {
//             blockList[i] = personMap[person].blockList[i];
//         }
//         return blockList;
//     }

//     /* ================ TRANSACTION FUNCTIONS ================ */

//     function share() external payable {
//         require(block.number < shareEndBlock, "block cannot over shareEndBlock!");
//         sharerMap[msg.sender].shareAmount += uint128(msg.value);
//         shareEthAmount += msg.value;
//         emit Share(msg.sender, msg.value);
//     }

//     function start() external {
//         require(block.number >= shareEndBlock, "block must over shareEndBlock!");
//         require(mintStartBlock == 0, "mint cannot start!");
//         weth.deposit{value: shareEthAmount}();
//         weth.transfer(address(pair), shareEthAmount);
//         _mint(address(pair), shareTokenAmount);
//         sharePairAmount = pair.mint(address(this));
//         mintStartBlock = block.number;
//         halvingBlock = block.number + halvingBlockAmount;
//         lastBlock = block.number;
//     }

//     function get(uint256 amount) external _checkMintStart {
//         uint256 maxAmount = maxGetAmount(msg.sender);
//         require(amount <= maxAmount, "cannot over maxAmount!");
//         sharerMap[msg.sender].getAmount += uint128(amount);
//         pair.transfer(msg.sender, amount);
//         emit Get(msg.sender, amount);
//     }

//     function mint() external _checkMintStart _checkHalving {
//         if (block.number != lastBlock) {
//             uint256 mintAmount = getMintAmount();
//             _mint(address(this), mintAmount);
//             blockMap[block.number].mintAmount = uint128(mintAmount / 2);
//             lastBlock = block.number;
//             _addPerStakeRewardAmount(blockMap[block.number].mintAmount);
//         }
//         Person storage person = personMap[msg.sender];
//         if (person.blockList.length == person.blockIndex) {
//             person.blockList.push(uint32(block.number));
//         } else {
//             person.blockList[person.blockIndex] = uint32(block.number);
//         }
//         emit Mint(msg.sender, blockMap[block.number].personAmount);
//         unchecked {
//             blockMap[block.number].personAmount++;
//             person.blockIndex++;
//         }
//     }

//     function claim() external _checkMintStart {
//         Person memory person = personMap[msg.sender];
//         require(person.blockList[person.blockIndex - 1] != block.number, "mint claim cannot in sample block!");
//         uint256 claimAmount;
//         unchecked {
//             for (uint256 i = 0; i < person.blockIndex; i++) {
//                 Block memory _block = blockMap[person.blockList[i]];
//                 claimAmount += _block.mintAmount / _block.personAmount;
//             }
//         }
//         personMap[msg.sender].blockIndex = 0;
//         token.transfer(msg.sender, claimAmount);
//         emit Claim(msg.sender, claimAmount);
//     }

//     function stake(uint256 amount) external _checkMintStart _checkReward {
//         pair.transferFrom(msg.sender, address(this), amount);
//         personMap[msg.sender].stakeAmount += uint128(amount);
//         stakeAmount += amount;
//         emit Stake(msg.sender, amount);
//     }

//     function withdrawStake(uint256 amount) public _checkMintStart _checkReward {
//         require(amount <= personMap[msg.sender].stakeAmount, "amount cannot over stakeAmount!");
//         personMap[msg.sender].stakeAmount -= uint128(amount);
//         stakeAmount -= amount;
//         pair.transfer(msg.sender, amount);
//         emit WithdrawStake(msg.sender, amount);
//     }

//     function withdrawReward() public _checkMintStart _checkReward {
//         uint256 rewardAmount = personMap[msg.sender].rewardAmount;
//         personMap[msg.sender].rewardAmount = 0;
//         token.transfer(msg.sender, rewardAmount);
//         emit WithdrawReward(msg.sender, rewardAmount);
//     }

//     function exit() external {
//         withdrawStake(personMap[msg.sender].stakeAmount);
//         withdrawReward();
//     }

//     function setFunder(address newFunder) external {
//         require(msg.sender == funder, "sender not funder!");
//         funder = newFunder;
//     }

//     function getFund() external {
        
//     }
// }
