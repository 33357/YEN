import { BigNumberish } from 'ethers';

export interface ShareEvent {
  person: string;
  amount: BigNumberish;
}

export interface GetEvent {
  person: string;
  amount: BigNumberish;
}

export interface MintEvent {
  person: string;
  index: BigNumberish;
}

export interface ClaimEvent {
  person: string;
  amount: BigNumberish;
}

export interface StakeEvent {
  person: string;
  amount: BigNumberish;
}

export interface WithdrawStakeEvent {
  person: string;
  amount: BigNumberish;
}

export interface WithdrawRewardEvent {
  person: string;
  amount: BigNumberish;
}

export interface Block {
  persons: BigNumberish;
  mints: BigNumberish;
}

export interface Person {
  blockIndex: BigNumberish;
  stakes: BigNumberish;
  rewards: BigNumberish;
  lastPerStakeRewards: BigNumberish;
}

export interface Sharer {
  shares: BigNumberish;
  getteds: BigNumberish;
}

export { ContractTransaction, ContractReceipt } from '@ethersproject/contracts';
