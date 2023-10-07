const { expect } = require("chai");
const hre = require("hardhat");

describe("TesoX Token Contract", () => {
  let Token;
  let tesoXToken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async () => {
    Token = await hre.ethers.getContractFactory("TSOXToken");
    [owner, addr1, addr2] = await hre.ethers.getSigners();

    tesoXToken = await Token.deploy();
  });

  describe("Deployment", () => {
    it("Should set the right owner", async () => {
      expect(await tesoXToken.owner()).to.equal(owner.address);
    });

    it("Should set the right name - TesoX", async function() {
      expect(await tesoXToken.name()).to.equal("TesoX");
    });

    it("Should set the right symbol - TSOX", async function() {
      expect(await tesoXToken.symbol()).to.equal("TSOX");
    });

    it("Should have initial total supply of 0", async () => {
      expect(await tesoXToken.totalSupply()).to.equal(0);
    });

    it("Should not allow non-owners to mint tokens", async () => {
      const amountToMint = 100;
      await expect(
        tesoXToken.connect(addr1).mint(addr1.address, amountToMint)
      ).to.be.revertedWith(
        `AccessControl: account ${addr1.address.toLowerCase()} is missing role ${await tesoXToken.MINTER_ROLE()}`
      );
    });

    it("Should mint tokens and increase total supply", async () => {
      const amountToMint = 100;
      await tesoXToken.mint(owner.address, amountToMint);

      const balanceOwner = await tesoXToken.balanceOf(owner.address);
      const totalSupply = await tesoXToken.totalSupply();

      expect(balanceOwner).to.equal(amountToMint);
      expect(totalSupply).to.equal(amountToMint);
    });
  });

  describe("Transaction ERC20 Burnable, Mintable Token", () => {
    it("Should burn tokens and decrease total supply", async () => {
      const amountToMint = 1000;
      const amountToBurn = 500;
      const amountAfterBurned = amountToMint - amountToBurn;
      await tesoXToken.mint(owner.address, amountToMint);

      await tesoXToken.burn(amountToBurn);

      const balanceOwner = await tesoXToken.balanceOf(owner.address);
      const totalSupply = await tesoXToken.totalSupply();

      expect(balanceOwner).to.equal(amountAfterBurned);
      expect(totalSupply).to.equal(amountToMint.sub(amountToBurn));
    });

    it("Should not allow burning more tokens then the balance", async () => {
      const amountToMint = 1000;
      const amountToBurn = 5000;

      await tesoXToken.mint(owner.address, amountToMint);

      await expect(tesoXToken.burn(amountToBurn)).to.be.revertedWith(
        "ERC20: burn amount exceeds balance"
      );
    });
  });
});
