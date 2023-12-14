import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 
Deploys a contract named "YourContract" using the deployer account and
constructor arguments set to the deployer address
*
@param hre HardhatRuntimeEnvironment object.
*/
const deployArbitrage: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g yarn deploy --network goerli), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with yarn generate which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the yarn account command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  //   const deployer = new ethers.Wallet(privateKey, ethers.provider);
  console.log("Deploying from MetaMask wallet address:", deployer);
  //  const deployerBalance = await ethers.provider.getBalance(deployer);

  await deploy("Arbitrage", {
    from: deployer,
    // Contract constructor arguments
    args: [],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract
  // const yourContract = await hre.ethers.getContract("YourContract", deployer);
};

export default deployArbitrage;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployArbitrage.tags = ["Arbitrage"];

// import { HardhatRuntimeEnvironment } from "hardhat/types";
// import { DeployFunction } from "hardhat-deploy/types";
// import { ethers } from "hardhat";
// //import dotenv from "dotenv";

// const deployArbitrage: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
//   const { deploy } = hre.deployments;

//   //const { deployer } = await hre.getNamedAccounts();
//   const privateKey = process.env.PRIVATE_KEY;
//   const deployer = new ethers.Wallet(privateKey, ethers.provider);
//   console.log("Deploying from MetaMask wallet address:", deployer.address);
//   const deployerBalance = await ethers.provider.getBalance(deployer.address);
//   console.log("Balance of MetaMask wallet:", ethers.utils.formatEther(deployerBalance));

//   //const deployerSigner = deployer.connect(ethers.provider); // Get signer instance

//   await deploy("Arbitrage", {
//     from: deployer.address,
//     log: true,
//     autoMine: true,
//   });
// };

// export default deployArbitrage;

// deployArbitrage.tags = ["Arbitrage"];
