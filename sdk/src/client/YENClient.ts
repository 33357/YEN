import {
  CallOverrides,
  PayableOverrides,
  BigNumber,
  BigNumberish
} from 'ethers';

export interface YENClient {
  address(): string;

  /* ================ VIEW FUNCTIONS ================ */

  blockMintAmount(config?: CallOverrides): Promise<BigNumber>;

  fee(config?: CallOverrides): Promise<BigNumber>;

  getBlockAmount(config?: CallOverrides): Promise<BigNumber>;

  getMintAmount(config?: CallOverrides): Promise<BigNumber>;

  getRewardAmount(address: string, config?: CallOverrides): Promise<BigNumber>;

  halvingBlock(config?: CallOverrides): Promise<BigNumber>;

  halvingBlockAmount(config?: CallOverrides): Promise<BigNumber>;

  lastBlock(config?: CallOverrides): Promise<BigNumber>;

  maxGetAmount(address: string, config?: CallOverrides): Promise<BigNumber>;

  mintStartBlock(config?: CallOverrides): Promise<BigNumber>;

  perStakeRewardAmount(config?: CallOverrides): Promise<BigNumber>;

  shareBlockAmount(config?: CallOverrides): Promise<BigNumber>;

  shareEndBlock(config?: CallOverrides): Promise<BigNumber>;

  shareEthAmount(config?: CallOverrides): Promise<BigNumber>;

  sharePairAmount(config?: CallOverrides): Promise<BigNumber>;

  shareTokenAmount(config?: CallOverrides): Promise<BigNumber>;

  stakeAmount(config?: CallOverrides): Promise<BigNumber>;

  /* ================ TRANSACTION FUNCTIONS ================ */

  share(config?: PayableOverrides, callback?: Function): Promise<void>;

  start(config?: PayableOverrides, callback?: Function): Promise<void>;

  get(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  mint(config?: PayableOverrides, callback?: Function): Promise<void>;

  claim(config?: PayableOverrides, callback?: Function): Promise<void>;

  stake(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  withdrawStake(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  withdrawReward(config?: PayableOverrides, callback?: Function): Promise<void>;

  exit(config?: PayableOverrides, callback?: Function): Promise<void>;
}
