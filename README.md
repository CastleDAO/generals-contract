# NFT


## Setup


compile the contract and deploy to the internal `hardhat` network

```
npx hardhat compile
npx hardhat run scripts/deploy.js
```

## Here's the next level

a real example requires you to run a local Ganache blockchain simulator (AKA the `localhost` network, chainId `31337`):

```shell
# in one terminal, run a lil blockchain
npx hardhat node --show-stack-traces

# in another terminal, deploy the contract and copy the deployed address
npx hardhat run --network localhost scripts/deploy.js
```

then start `npx hardhat console` and you can interact with said contract

```shell
npx hardhat console --network localhost
```

in the console, connect to our newly deployed `MyContract`:

```javascript
const Contract = await ethers.getContractFactory('MyContract');
const contract = await Contract.attach("ADDRESS_FROM_DEPLOYMENT_GOES_HERE");
```

then let's call some contract methods:

```javascript
(await contract.name()).toString()
// 'ClastlesLootGenOne'

(await contract.totalSupply()).toString();
// '0'
// (because we haven't minted anything yet)

(await contract.getWarriorName(1)).toString();

(await contract.getName(1)).toString();

// 'none'

(await contract.traitsOf(1)).toString();
```

if you want some castles, mint them to one of the default accounts setup by `hardhat node` (ganache). 

```javascript
let tokenId = 8012;
let account = (await ethers.getSigners())[0];
let txn = (await contract.connect(account).mint(tokenId));
let receipt = (await txn.wait());
console.log(receipt.events[0].args)
/*
[
  from: '0x0000000000000000000000000000000000000000',
  to: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
  tokenId: BigNumber { _hex: '0x03', _isBigNumber: true }
]
*/
```

did it work though?
```javascript
(await contract.totalSupply()).toString();
// '1'

```



## Deploy 

This largely requires funding a wallet and registering API keys with [Alchemy](https://docs.alchemy.com/alchemy/introduction/getting-started) and [Etherscan]()

Copy `.env.sample` to `.env` and edit in your keys

Then:

```shell
npx hardhat run scripts/deploy.js --network rinkeby
```

you can interact with this contract via `npx hardhat console` the same way as above, just substitute `--network rinkeby` for `--network localhost`

You can also use the `hardhat-etherscan-verify` plugin to verify the contract on Etherscan, which is required to be truly eleet

```
npx hardhat verify --network rinkeby <YOUR_CONTRACT_ADDRESS>
```

Substitute `mainnet` for `rinkeby` to deploy for realsies. good luck


# more reading

* [Hardhat docs](https://hardhat.org/getting-started/)
* [OpenZeppelin docs](https://docs.openzeppelin.com/openzeppelin/)


## Testing on ropsten
npx hardhat console --network ropsten


```
const Contract = await ethers.getContractFactory('MyContract');
const contract = await Contract.attach('ADDRESS');

(await contract.getName(1)).toString();
```


## Inspirations
https://etherscan.io/address/0x521f9c7505005cfa19a8e5786a9c3c9c9f5e6f42#code

- Partners https://arbiscan.io/address/0x4de95c1E202102E22E801590C51D7B979f167FBB#code

https://nft.storage/#getting-started


## Ropsten test

- Castles contract https://ropsten.etherscan.io/address/0xf22E6c12372b1bE8ba63EfFacAf1C8688e4A222A#code
- npx hardhat verify --network ropsten