import { BigNumber } from 'ethers';

export interface ShareEvent {
  person: string;
  amount: BigNumber;
}

export interface GetEvent {
  person: string;
  amount: BigNumber;
}

export interface MintEvent {
  person: string;
  index: BigNumber;
}

export interface ClaimEvent {
  person: string;
  amount: BigNumber;
}

export interface StakeEvent {
  person: string;
  amount: BigNumber;
}

export interface WithdrawStakeEvent {
  person: string;
  amount: BigNumber;
}

export interface WithdrawRewardEvent {
  person: string;
  amount: BigNumber;
}

export interface Block {
  persons: BigNumber;
  mints: BigNumber;
}

export interface Person {
  blockIndex: BigNumber;
  stakes: BigNumber;
  rewards: BigNumber;
  lastPerStakeRewards: BigNumber;
}

export interface Sharer {
  shares: BigNumber;
  getteds: BigNumber;
}

export { ContractTransaction, ContractReceipt } from '@ethersproject/contracts';
