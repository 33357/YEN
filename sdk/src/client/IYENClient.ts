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

  getFeeMul(config?: CallOverrides): Promise<BigNumber>;

  blockMints(config?: CallOverrides): Promise<BigNumber>;

  getBlocks(config?: CallOverrides): Promise<BigNumber>;

  getMints(config?: CallOverrides): Promise<BigNumber>;

  getRewards(address: string, config?: CallOverrides): Promise<BigNumber>;

  halvingBlock(config?: CallOverrides): Promise<BigNumber>;

  halvingBlocks(config?: CallOverrides): Promise<BigNumber>;

  lastBlock(config?: CallOverrides): Promise<BigNumber>;

  getShares(address: string, config?: CallOverrides): Promise<BigNumber>;

  mintStartBlock(config?: CallOverrides): Promise<BigNumber>;

  perStakeRewards(config?: CallOverrides): Promise<BigNumber>;

  shareEndBlock(config?: CallOverrides): Promise<BigNumber>;

  shareEths(config?: CallOverrides): Promise<BigNumber>;

  sharePairs(config?: CallOverrides): Promise<BigNumber>;

  shareTokens(config?: CallOverrides): Promise<BigNumber>;

  stakes(config?: CallOverrides): Promise<BigNumber>;

  blockMap(
    blockNumber: BigNumberish,
    config?: CallOverrides
  ): Promise<YENModel.Block>;

  personMap(person: string, config?: CallOverrides): Promise<YENModel.Person>;

  sharerMap(sharer: string, config?: CallOverrides): Promise<YENModel.Sharer>;

  getPersonBlockList(person: string, config?: CallOverrides): Promise<number[]>;

  getClaims(person: string, config?: CallOverrides): Promise<BigNumber>;

  name(config?: CallOverrides): Promise<string>;

  symbol(config?: CallOverrides): Promise<string>;

  decimals(config?: CallOverrides): Promise<number>;

  totalSupply(config?: CallOverrides): Promise<BigNumber>;

  balanceOf(account: string, config?: CallOverrides): Promise<BigNumber>;

  allowance(
    owner: string,
    spender: string,
    config?: CallOverrides
  ): Promise<BigNumber>;

  pair(
    config?: CallOverrides
  ): Promise<string>;

  /* ================ TRANSACTION FUNCTIONS ================ */

  share(config?: PayableOverrides, callback?: Function): Promise<void>;

  start(config?: PayableOverrides, callback?: Function): Promise<void>;

  getShare(
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

  transfer(
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  approve(
    spender: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  transferFrom(
    sender: string,
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;
}
