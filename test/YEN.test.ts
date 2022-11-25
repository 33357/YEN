import {expect} from 'chai';
import {ethers, getNamedAccounts} from 'hardhat';
import {Signer} from 'ethers';
import pino from 'pino';
import {YENClient} from '../sdk/dist';

const Logger = pino();
const contractName = 'YEN';

describe(`test ${contractName}`, function () {
  let deployer: Signer;
  let accountA: Signer;

  before('setup accounts', async () => {
    const NamedAccounts = await getNamedAccounts();
    deployer = await ethers.getSigner(NamedAccounts.deployer);
    accountA = await ethers.getSigner(NamedAccounts.accountA);
  });

  describe(`test sdk`, function () {
    let yen: YENClient;

    beforeEach('deploy and init contract', async () => {
      const Contract = await ethers.getContractFactory(`${contractName}`);
      const contractResult = await Contract.connect(deployer).deploy();
      yen = new YENClient(deployer, contractResult.address);
      Logger.info(`deployed ${contractName}`);
    });

    it('check init data', async function () {});
  });
});
