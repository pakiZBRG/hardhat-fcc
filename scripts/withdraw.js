const { getNamedAccounts, ethers } = require('hardhat');

async function main() {
    const { deployer } = getNamedAccounts();
    const fundMe = await ethers.getContract('FundMe', deployer);
    console.log('Withdrawing from contract...')
    const transcationResponse = await fundMe.withdraw();
    await transcationResponse.wait(1);
    console.log('Withdrawn')
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    })