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

    const result = await myContract.mint({
      value: price,
    });

    expect(result).to.emit(myContract, "Transfer");
    expect(result).to.emit(myContract, "GeneralCreated");

    const receipt = await result.wait();

    const generalCreatedEvent = receipt.events.find( i => i.event === 'GeneralCreated');

    expect(generalCreatedEvent.args[0]).to.equal('Crypto General');
    expect(generalCreatedEvent.args[1]).to.equal(1);


    const general = await myContract.generals(1);
    expect(general.name).to.equal('Crypto General');

    expect(general.strength.toNumber()).to.be.greaterThan(0);
    expect(general.defense.toNumber()).to.be.greaterThan(0);
    expect(general.intelligence.toNumber()).to.be.greaterThan(0);
    expect(general.agility.toNumber()).to.be.greaterThan(0);
    expect(general.abilityPower.toNumber()).to.be.greaterThan(0);
    expect(general.magicResistance.toNumber()).to.be.greaterThan(0);
    expect(general.constitution.toNumber()).to.be.greaterThan(0);
    expect(general.speed.toNumber()).to.be.greaterThan(0);
    expect(general.charisma.toNumber()).to.be.greaterThan(0);
    expect(general.createdAt.toNumber()).to.be.greaterThan(0);

    expect(general.level.toNumber()).to.equal(1);

   });

   it("Should do a mint with name correctly", async function () {
    const price = await myContract.price();

    const result = await myContract.mintWithName('pepe', {
      value: price
    });

    expect(result).to.emit(myContract, "Transfer");
    expect(result).to.emit(myContract, "GeneralCreated");

    const receipt = await result.wait();

    const generalCreatedEvent = receipt.events.find( i => i.event === 'GeneralCreated');

    expect(generalCreatedEvent.args[0]).to.equal('pepe');
    expect(generalCreatedEvent.args[1]).to.equal(2);


    const general = await myContract.generals(2);
    expect(general.name).to.equal('pepe');

    expect(general.strength.toNumber()).to.be.greaterThan(0);
    expect(general.defense.toNumber()).to.be.greaterThan(0);
    expect(general.intelligence.toNumber()).to.be.greaterThan(0);
    expect(general.agility.toNumber()).to.be.greaterThan(0);
    expect(general.abilityPower.toNumber()).to.be.greaterThan(0);
    expect(general.magicResistance.toNumber()).to.be.greaterThan(0);
    expect(general.constitution.toNumber()).to.be.greaterThan(0);
    expect(general.speed.toNumber()).to.be.greaterThan(0);
    expect(general.charisma.toNumber()).to.be.greaterThan(0);
    expect(general.createdAt.toNumber()).to.be.greaterThan(0);

    expect(general.level.toNumber()).to.equal(1);

   });

   
  it("Can do a quest", async function () {

    const exp = await myContract.experience(1);
    expect(exp.toNumber()).to.eq(0);

    const result = await myContract.quest(1);
    expect(result).to.emit(myContract, "Quest");

    const receipt = await result.wait();

    const questEvent = receipt.events.find( i => i.event === 'Quest');

    expect(questEvent.args[0]).to.equal(1);
    expect(questEvent.args[1].toNumber()).to.be.greaterThan(100);
    expect(questEvent.args[2].toNumber()).to.be.greaterThan(100);
    const expNew = await myContract.experience(1);
    expect(expNew.toNumber()).to.eq(questEvent.args[2].toNumber());
  });

  it("Can not do a new quest inmediatlelly", async function () {
    expect( myContract.quest(1)).to.be.revertedWith('Too early to do a new quest')
  });

  it('Can level up', async function () {

    const exp = await myContract.experience(1);
    expect(exp.toNumber()).to.be.greaterThan(0);
    const general = await myContract.generals(1);


    const result = await myContract.levelUp(1);
    expect(result).to.emit(myContract, "ExperienceSpent");
    expect(result).to.emit(myContract, "LeveledUp");
    const receipt = await result.wait();

    const leveledUpEvent = receipt.events.find( i => i.event === 'LeveledUp');
    const experienceSpentEvent = receipt.events.find( i => i.event === 'ExperienceSpent');

    expect(experienceSpentEvent.args[0]).to.equal(1);
    expect(experienceSpentEvent.args[1].toNumber()).to.equal(100);
    expect(experienceSpentEvent.args[2].toNumber()).to.equal(exp.toNumber() - 100);


    expect(leveledUpEvent.args[1]).to.equal(1);
    expect(leveledUpEvent.args[2]).to.equal(2);

    const expNew = await myContract.experience(1);
    expect(expNew.toNumber()).to.eq(experienceSpentEvent.args[2].toNumber());

    const genNew = await myContract.generals(1);

    expect(genNew.strength.toNumber()).to.be.eq(general.strength.toNumber() + 1);
    expect(genNew.defense.toNumber()).to.be.eq(general.defense.toNumber() + 1);
    expect(genNew.intelligence.toNumber()).to.be.eq(general.intelligence.toNumber() + 1);
    expect(genNew.agility.toNumber()).to.be.eq(general.agility.toNumber() + 1);
    expect(genNew.abilityPower.toNumber()).to.be.eq(general.abilityPower.toNumber() + 1);
    expect(genNew.magicResistance.toNumber()).to.be.eq(general.magicResistance.toNumber() + 1);
    expect(genNew.constitution.toNumber()).to.be.eq(general.constitution.toNumber() + 1);
    expect(genNew.speed.toNumber()).to.be.eq(general.speed.toNumber() + 1);
    expect(genNew.charisma.toNumber()).to.be.eq(general.charisma.toNumber() + 1);

    expect(genNew.level.toNumber()).to.be.eq(2);
  });

  it("Can not do a level up again", async function () {
    expect( myContract.levelUp(1)).to.be.revertedWith('Not enough experience')
  });

});
