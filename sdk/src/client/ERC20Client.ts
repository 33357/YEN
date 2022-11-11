import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  Signer
} from 'ethers';
import { IERC20Client } from './';
import { ERC20, ERC20__factory } from '../typechain';

export class EtherERC20Client implements IERC20Client {
  private _contract: ERC20;
  private _errorTitle = 'ERC20Client';
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
    this._contract = ERC20__factory.connect(address, this._provider);
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

  public async name(config?: CallOverrides): Promise<string> {
    return this._contract.name({ ...config });
  }

  public async symbol(config?: CallOverrides): Promise<string> {
    return this._contract.symbol({ ...config });
  }

  public async decimals(config?: CallOverrides): Promise<number> {
    return this._contract.decimals({ ...config });
  }

  public async totalSupply(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.totalSupply({ ...config });
  }

  public async balanceOf(
    account: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.balanceOf(account, { ...config });
  }

  public async allowance(
    owner: string,
    spender: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.allowance(owner, spender, { ...config });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  public async transfer(
    recipient: string,
    amount: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.transfer(recipient, amount, {
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
    const transaction = await this._contract.approve(spender, amount, {
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
    const transaction = await this._contract.transferFrom(
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
