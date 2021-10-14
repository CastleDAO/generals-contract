const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyContract", function () {
  let myContract;

  this.beforeAll(async () => {
    const MyContract = await ethers.getContractFactory("MyContract");
    myContract = await MyContract.deploy();
    await myContract.deployed();
  });

  it("Should do a mint correctly", async function () {
    const price = await myContract.price();

    console.log("price", price);
    const result = await myContract.mint({
      value: price,
    });

    expect(result).to.emit(myContract, "Transfer");

    //console.log(result)
    const defense = await myContract.getDefense(1);
    const wisdom = await myContract.getWisdom(1);
    const soul = await myContract.getSoul(1);
    const attack = await myContract.getAttack(1);
    const rarityNumber = await myContract.getRarityNumber(1);
    const type = await myContract.getType(1);


    expect(type.length).to.be.greaterThan(0);
    expect(type).to.equal("reincarnate");
    
   
    expect(rarityNumber.toNumber()).to.be.greaterThan(0);
    expect(defense.toNumber()).to.be.greaterThan(20);
    expect(attack.toNumber()).to.be.greaterThan(20);
    expect(wisdom.toNumber()).to.be.greaterThan(20);
    expect(soul.toNumber()).to.be.greaterThan(20);
   });


   it("Should do aanother correctly", async function () {
    const price = await myContract.price();

    const result = await myContract.mint({
      value: price,
    });

    expect(result).to.emit(myContract, "Transfer");

    //console.log(result)
    const defense = await myContract.getDefense(2);
    const wisdom = await myContract.getWisdom(2);
    const soul = await myContract.getSoul(2);
    const attack = await myContract.getAttack(2);
    const rarityNumber = await myContract.getRarityNumber(2);
    const type = await myContract.getType(2);

    const traits = await myContract.traitsOf(2);
    console.log(traits)
    expect(type.length).to.be.greaterThan(0);
    expect(type).to.equal("demon");
    expect(rarityNumber.toNumber()).to.be.greaterThan(0);
    expect(defense.toNumber()).to.be.greaterThan(20);
    expect(attack.toNumber()).to.be.greaterThan(20);
    expect(wisdom.toNumber()).to.be.greaterThan(20);
    expect(soul.toNumber()).to.be.greaterThan(20);
   });


});
