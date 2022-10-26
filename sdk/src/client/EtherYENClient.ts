import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  BigNumberish,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  Signer
} from 'ethers';
import { YENClient } from '..';
import { YEN, YEN__factory } from '../typechain';

export class EtherYENClient implements YENClient {
  protected _provider: Provider | Signer;
  protected _waitConfirmations = 3;
  private _contract: YEN;
  private _errorTitle = 'EtherYENClient';

  constructor(
    provider: Provider | Signer,
    address: string,
    waitConfirmations?: number
  ) {
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
    this._provider = provider;
    this._contract = YEN__factory.connect(address, this._provider);
  }

  public address(): string {
    return this._contract.address;
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
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
  }

  /* ================ VIEW FUNCTIONS ================ */

  public async blockMintAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.blockMintAmount({ ...config });
  }

  public async fee(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.fee({ ...config });
  }

  public async getBlockAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.getBlockAmount({ ...config });
  }

  public async getMintAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.getMintAmount({ ...config });
  }

  public async getRewardAmount(
    address: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.getRewardAmount(address, { ...config });
  }

  public async halvingBlock(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.halvingBlock({ ...config });
  }

  public async halvingBlockAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.halvingBlockAmount({ ...config });
  }

  public async lastBlock(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.lastBlock({ ...config });
  }

  public async maxGetAmount(
    address: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.maxGetAmount(address, { ...config });
  }

  public async mintStartBlock(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.mintStartBlock({ ...config });
  }

  public async perStakeRewardAmount(
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.perStakeRewardAmount({ ...config });
  }

  public async shareBlockAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.shareBlockAmount({ ...config });
  }

  public async shareEndBlock(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.shareEndBlock({ ...config });
  }

  public async shareEthAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.shareEthAmount({ ...config });
  }

  public async sharePairAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.sharePairAmount({ ...config });
  }

  public async shareTokenAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.shareTokenAmount({ ...config });
  }

  public async stakeAmount(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.stakeAmount({ ...config });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  public async share(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.connect(this._provider).share({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async start(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.connect(this._provider).start({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async get(
    amount: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract
      .connect(this._provider)
      .get(amount, {
        ...config
      });
    this._afterTransaction(transaction, callback);
  }

  public async mint(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.connect(this._provider).mint({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async claim(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.connect(this._provider).claim({
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
    const transaction = await this._contract
      .connect(this._provider)
      .stake(amount, {
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
    const transaction = await this._contract
      .connect(this._provider)
      .withdrawStake(amount, {
        ...config
      });
    this._afterTransaction(transaction, callback);
  }

  public async withdrawReward(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract
      .connect(this._provider)
      .withdrawReward({
        ...config
      });
    this._afterTransaction(transaction, callback);
  }

  public async exit(
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.connect(this._provider).exit({
      ...config
    });
    this._afterTransaction(transaction, callback);
  }
}
