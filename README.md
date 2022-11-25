# uniswap-v2-contract

## Sample Scripts
### Install dependencies
```bash
yarn
```

### Compile contracts
```bash
yarn build
```

### Hardhat test
```bash
yarn test 
```

### Hardhat solidity-coverage
```bash
yarn test:cov
```

## SOP
### environment
#### localhost 

#### goerli
``` bash
export ENV_FILE='./envs/goerli.env'
export NETWORK_ID=5
export WAIT_NUM=1
export GAS_PRICE=10
```

#### eth
``` bash
export ENV_FILE='./envs/eth.env'
export NETWORK_ID=1
export WAIT_NUM=3
export GAS_PRICE=30
```

### script

#### deploy script
```bash
yarn run env-cmd -f $ENV_FILE yarn run hardhat contract:deploy --contract YEN --gas-price $GAS_PRICE --args [] --network $NETWORK_ID --wait-num $WAIT_NUM
```

#### verify contract
```bash
yarn run env-cmd -f $ENV_FILE yarn run hardhat contract:verify --contract YEN --network $NETWORK_ID --args []
```