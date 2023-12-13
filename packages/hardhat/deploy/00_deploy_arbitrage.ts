import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployHelloWorld: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  console.log("deployer = ", deployer);
  //console.log("balance = ", IERC20(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43).balanceOf(deployer);``
  const deployerBalance = await hre.ethers.provider.getBalance(deployer);
  console.log("balance = ", hre.ethers.utils.formatEther(deployerBalance));

  await deploy("Arbitrage", {
    from: deployer,
    log: true,
    autoMine: true,
  });
};

export default deployHelloWorld;

deployHelloWorld.tags = ["Arbitrage"];
