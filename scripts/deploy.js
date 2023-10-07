const hre = require("hardhat");

async function main() {
  const [developer] = await hre.ethers.getSigners();

  // TSOXToken smart contract
  const TsoxToken = await hre.ethers.getContractFactory("TSOXToken");
  const tsoxToken = await TsoxToken.deploy();

  // TSOXMasterChef smart contract
  const tsoxPerBlock = 100;
  const startBlock = 43048;
  const multiplier = 1;

  const TsoxMasterChef = await hre.ethers.getContractFactory(
    "TSOXMasterChefV1"
  );
  const tsoxMasterChef = await TsoxMasterChef.deploy(
    tsoxToken.target,
    developer.address,
    tsoxPerBlock,
    startBlock,
    multiplier
  );

  console.log("TSOXToken deployed to: ", tsoxToken.target);
  console.log("TSOXMasterChef deployed to: ", tsoxMasterChef.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => {
    console.log("All smart contracts deployed");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
