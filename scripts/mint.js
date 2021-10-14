const hre = require("hardhat");

async function main () {
    const Contract = await hre.ethers.getContractFactory("MyContract");
    const contract = await Contract.attach('address');

    (await contract.mint());
}
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
