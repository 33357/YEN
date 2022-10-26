import {expect} from 'chai';
import {ethers, getNamedAccounts} from 'hardhat';
import {Signer} from 'ethers';
import pino from 'pino';
import {EtherYENClient} from '../sdk/dist';
import {YEN} from '../sdk/src/typechain';

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
    let contract: EtherYENClient;

    beforeEach('deploy and init contract', async () => {
      const Contract = await ethers.getContractFactory(`${contractName}`);
      const contractResult = await Contract.connect(deployer).deploy();
      contract = new EtherYENClient(deployer, contractResult.address);
      Logger.info(`deployed ${contractName}`);
    });

    it('check init data', async function () {});
  });

  describe(`test contract`, function () {
    let contract: YEN;

    beforeEach('deploy and init contract', async () => {
      const Contract = await ethers.getContractFactory(contractName);
      contract = (await Contract.deploy()) as YEN;
      Logger.info(`deployed ${contractName}`);
    });

    it('check admin', async function () {});
  });
});
