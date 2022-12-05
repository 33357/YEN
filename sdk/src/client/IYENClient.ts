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

  blockMints(config?: CallOverrides): Promise<BigNumber>;

  getMints(config?: CallOverrides): Promise<BigNumber>;

  getRewards(address: string, config?: CallOverrides): Promise<BigNumber>;

  halvingBlock(config?: CallOverrides): Promise<BigNumber>;

  halvingBlocks(config?: CallOverrides): Promise<BigNumber>;

  lastBlock(config?: CallOverrides): Promise<BigNumber>;

  stakes(config?: CallOverrides): Promise<BigNumber>;

  blockMap(
    blockNumber: BigNumberish,
    config?: CallOverrides
  ): Promise<YENModel.Block>;

  personMap(person: string, config?: CallOverrides): Promise<YENModel.Person>;

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

  pair(config?: CallOverrides): Promise<string>;

  /* ================ TRANSACTION FUNCTIONS ================ */

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
