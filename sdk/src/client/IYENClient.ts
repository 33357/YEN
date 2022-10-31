import {
  CallOverrides,
  PayableOverrides,
  BigNumber,
  BigNumberish
} from 'ethers';
import { YENModel } from 'src/model';

export interface IYENClient {
  address(): string;

  /* ================ VIEW FUNCTIONS ================ */

  blockMintAmount(config?: CallOverrides): Promise<BigNumber>;

  stakerFee(config?: CallOverrides): Promise<BigNumber>;

  funderFee(config?: CallOverrides): Promise<BigNumber>;

  funder(config?: CallOverrides): Promise<string>;

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

  blockMap(
    blockNumber: BigNumberish,
    config?: CallOverrides
  ): Promise<YENModel.Block>;

  personMap(person: string, config?: CallOverrides): Promise<YENModel.Person>;

  sharerMap(sharer: string, config?: CallOverrides): Promise<YENModel.Sharer>;

  getPersonBlockList(person: string, config?: CallOverrides): Promise<number[]>;

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