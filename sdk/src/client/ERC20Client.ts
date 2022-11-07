import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  Signer
} from 'ethers';
import { IERC20Client } from '..';
import { ERC20, ERC20__factory } from '../typechain';

export class ERC20Client implements IERC20Client {
  private _erc20: ERC20;
  protected _provider: Provider | Signer;
  protected _waitConfirmations = 1;
  protected _errorTitle = 'ERC20Client';

  constructor(
    provider: Provider | Signer,
    address: string,
    waitConfirmations?: number
  ) {
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
    this._erc20 = ERC20__factory.connect(address, provider);
    this._provider = provider;
  }

  public address(): string {
    return this._erc20.address;
  }

  /* ================ UTILS FUNCTIONS ================ */

  protected _beforeTransaction() {
    if (this._provider instanceof Provider) {
      throw `${this._errorTitle}: no singer`;
    }
  }

  protected async _afterTransaction(
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

  public async name(config?: CallOverrides): Promise<string> {
    return this._erc20.name({ ...config });
  }

  public async symbol(config?: CallOverrides): Promise<string> {
    return this._erc20.symbol({ ...config });
  }

  public async decimals(config?: CallOverrides): Promise<number> {
    return this._erc20.decimals({ ...config });
  }

  public async totalSupply(config?: CallOverrides): Promise<BigNumber> {
    return this._erc20.totalSupply({ ...config });
  }

  public async balanceOf(
    account: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._erc20.balanceOf(account, { ...config });
  }

  public async allowance(
    owner: string,
    spender: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._erc20.allowance(owner, spender, { ...config });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  public async transfer(
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._erc20
      .connect(this._provider)
      .transfer(recipient, amount, {
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
    const transaction = await this._erc20
      .connect(this._provider)
      .approve(spender, amount, { ...config });
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
    const transaction = await this._erc20
      .connect(this._provider)
      .transferFrom(sender, recipient, amount, {
        ...config
      });
    this._afterTransaction(transaction, callback);
  }
}
