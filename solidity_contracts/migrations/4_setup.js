const MockUSDC = artifacts.require("MockUSDC");
const EscrowFactory = artifacts.require("EscrowFactory");

module.exports = async function (deployer) {
    try {
        // Get the deployed contract instances
        const usdcInstance = await MockUSDC.deployed();
        const factoryEscrow = await EscrowFactory.deployed();

        console.log("Setting up the contracts...");

        // Store the USDC address in the EscrowFactory
        await factoryEscrow.storeMockStablecoinAddress(usdcInstance.address);
        console.log("Mock USDC address stored in EscrowFactory");

        // Verify that the stablecoin address was stored correctly
        const storedAddress = await factoryEscrow.getStablecoinAddress();
        console.log("Stored Mock Stablecoin Address:", storedAddress);

        if (storedAddress === usdcInstance.address) {
            console.log("Setup completed successfully.");
        } else {
            console.error("Error: Stablecoin address mismatch.");
        }

    } catch (error) {
        console.error("Error during setup:", error);
    }
};