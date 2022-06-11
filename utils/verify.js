const { run } = require("hardhat");

async function verify(contractAddress, args) {
  console.log("Veryfing contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (error) {
    console.log("Error during veryfing", error.message);
  }
}

module.exports = { verify };
