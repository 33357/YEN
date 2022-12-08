import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  BigNumberish,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  Signer
} from 'ethers';
import { YENModel } from 'src/model';
import { IYENClient } from '.';
import { YEN, YEN__factory } from '../typechain';

export class YENClient implements IYENClient {
  public yen: YEN;
  private _errorTitle = 'YENClient';
  private _provider: Provider | Signer;
  private _waitConfirmations = 1;

  constructor(
    provider: Provider | Signer,
    address: string,
    waitConfirmations?: number
  ) {
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
    this._provider = provider;
    this.yen = YEN__factory.connect(address, this._provider);
  }

  public address(): string {
    return this.yen.address;
  }

  /* ================ UTILS FUNCTIONS ================ */

  private _beforeTransaction() {
    if (this._provider instanceof Provider) {
      throw `${this._errorTitle}: no singer`;
    }
  }

  private async _afterTransaction(
    transaction: ContractTransaction,
    callback?: Function
  ): Promise<any> {
    if (callback) {
      callback(transaction);this.yen
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
  }

  /* ================ VIEW FUNCTIONS ================ */

  public async blockMints(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.blockMints({ ...config });
  }

  public async getMints(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.getMints({ ...config });
  }

  public async getRewards(
    address: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this.yen.getRewards(address, { ...config });
  }

  public async halvingBlock(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.halvingBlock({ ...config });
  }

  public async halvingBlocks(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.halvingBlocks({ ...config });
  }

  public async lastBlock(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.lastBlock({ ...config });
  }

  public async perStakeRewards(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.perStakeRewards({ ...config });
  }

  public async stakes(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.stakes({ ...config });
  }

  public async blockMap(
    blockNumber: BigNumberish,
    config?: CallOverrides
  ): Promise<YENModel.Block> {
    return this.yen.blockMap(blockNumber, { ...config });
  }

  public async personMap(
    person: string,
    config?: CallOverrides
  ): Promise<YENModel.Person> {
    return this.yen.personMap(person, { ...config });
  }

  public async getPersonBlockList(
    person: string,
    config?: CallOverrides
  ): Promise<number[]> {
    return this.yen.getPersonBlockList(person, { ...config });
  }

  public async getClaims(
    person: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this.yen.getClaims(person, { ...config });
  }

  public async name(config?: CallOverrides): Promise<string> {
    return this.yen.name({ ...config });
  }

  public async symbol(config?: CallOverrides): Promise<string> {
    return this.yen.symbol({ ...config });
  }

  public async decimals(config?: CallOverrides): Promise<number> {
    return this.yen.decimals({ ...config });
  }

  public async totalSupply(config?: CallOverrides): Promise<BigNumber> {
    return this.yen.totalSupply({ ...config });
  }

  public async balanceOf(
    account: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this.yen.balanceOf(account, { ...config });
  }

  public async allowance(
    owner: string,
    spender: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this.yen.allowance(owner, spender, { ...config });
  }

  public async pair(config?: CallOverrides): Promise<string> {
    return this.yen.pair({ ...config });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  public async mint(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.mint({
      ...config,
      gasLimit:200000
    });
    this._afterTransaction(transaction, callback);
  }

  public async claim(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.claim({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async stake(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.stake(amount, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async withdrawStake(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.withdrawStake(amount, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async withdrawReward(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.withdrawReward({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async exit(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.exit({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async transfer(
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.transfer(recipient, amount, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async approve(
    spender: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.approve(spender, amount, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async transferFrom(
    sender: string,
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this.yen.transferFrom(
      sender,
      recipient,
      amount,
      {
        ...config
      }
    );
    this._afterTransaction(transaction, callback);
  }
}
