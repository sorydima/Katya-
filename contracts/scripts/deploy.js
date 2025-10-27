// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ChatContract = await hre.ethers.getContractFactory("ChatContract");
  const chatContract = await ChatContract.deploy();

  await chatContract.deployed();

  console.log("ChatContract deployed to:", chatContract.address);
  
  // Save the contract address to a file for frontend use
  const fs = require('fs');
  const path = require('path');
  
  const contractAddressPath = path.join(__dirname, '..', 'contract-address.json');
  const contractAddress = {
    chatContract: chatContract.address
  };
  
  fs.writeFileSync(
    contractAddressPath,
    JSON.stringify(contractAddress, null, 2)
  );
  
  console.log(`Contract address saved to ${contractAddressPath}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
