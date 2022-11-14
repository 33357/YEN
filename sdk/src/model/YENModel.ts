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
  personAmount: BigNumberish;
  mintAmount: BigNumberish;
}

export interface Person {
  blockIndex: BigNumberish;
  stakeAmount: BigNumberish;
  rewardAmount: BigNumberish;
  lastPerStakeRewardAmount: BigNumberish;
}

export interface Sharer {
  shareAmount: BigNumberish;
  gettedAmount: BigNumberish;
}

export { ContractTransaction, ContractReceipt } from '@ethersproject/contracts';
