import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
//import dotenv from "dotenv";

const deployArbitrage: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy } = hre.deployments;

  //const { deployer } = await hre.getNamedAccounts();
  const privateKey = process.env.PRIVATE_KEY;
  const deployer = new ethers.Wallet(privateKey, ethers.provider);
  console.log("Deploying from MetaMask wallet address:", deployer.address);
  const deployerBalance = await ethers.provider.getBalance(deployer.address);
  console.log("Balance of MetaMask wallet:", ethers.utils.formatEther(deployerBalance));

  //const deployerSigner = deployer.connect(ethers.provider); // Get signer instance

  await deploy("Arbitrage", {
    from: deployer.address,
    log: true,
    autoMine: true,
  });
};

export default deployArbitrage;

deployArbitrage.tags = ["Arbitrage"];
