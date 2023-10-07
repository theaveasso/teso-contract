const { expect } = require("chai");
const hre = require("hardhat");

describe("TesoX MasterChef Contract", () => {
  let Token;
  let MasterChef;
  let owner;
  let tesoXToken;
  let masterChefInstance;

  beforeEach(async () => {
    Token = await hre.ethers.getContractFactory("TSOXToken");
    tesoXToken = await Token.deploy();

    [owner] = hre.ethers.getSigners();

    MasterChef = await hre.ethers.getContractFactory("TSOXMasterChef");
    masterChefInstance = await MasterChef.deploy(
      tesoXToken.target,
      owner.address,
      2,
      23452,
      1
    );
  });

  describe("MasterChef SmartContract Test suits", () => {
    it("", async () => {
      console.log("MasterChef", masterChefInstance);
    });
  });
});
