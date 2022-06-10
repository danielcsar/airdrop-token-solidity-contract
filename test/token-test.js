const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token", function () {
  it("Should return the correct total supply of the contract", async function () {
    const Token = await ethers.getContractFactory("CryptoToken");
    const token = await Token.deploy(100);
    await token.deployed();

    const totalSupplyExpected = 100;
    const totalSupplyResult = await token.totalSupply();

    expect(totalSupplyExpected).to.equal(totalSupplyResult);
  });

  it("Should return the correct balance", async function () {
    const [ owner, wallet1 ] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("CryptoToken", owner);
    const token = await Token.deploy(100);
    await token.deployed();

    const ownerBalanceExpected = 100;
    const ownerBalance = await token.balanceOf(owner.address);

    expect(ownerBalanceExpected).to.equal(ownerBalance);

    const wallet1BalanceExpected = 0;
    const wallet1Balance = await token.balanceOf(wallet1.address);

    expect(wallet1BalanceExpected).to.equal(wallet1Balance);
  });

  it("Should transfer the correct value", async function () {
    const [ owner, wallet1 ] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("CryptoToken", owner);
    const token = await Token.deploy(100);
    await token.deployed();

    const ownerBalanceExpected = 100;
    const transferedValue = 50;
    const ownerBalance = await token.balanceOf(owner.address);

    expect(ownerBalanceExpected).to.equal(ownerBalance);

    const wallet1BalanceExpected = 0;
    const wallet1Balance = await token.balanceOf(wallet1.address);

    expect(wallet1BalanceExpected).to.equal(wallet1Balance);

    //Transaction
    await token.connect(owner).transfer(wallet1.address, 50);
    
    const newOwnerBalance = await token.balanceOf(owner.address);
    const newWallet1Balance = await token.balanceOf(wallet1.address);

    expect(newOwnerBalance).to.equal(transferedValue);
    expect(newWallet1Balance).to.equal(transferedValue);
  });
});
