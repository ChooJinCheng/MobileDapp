const { ethers } = require("hardhat");

async function main() {
    console.log("Starting deployment...");

    // Deploy EscrowFactory
    const EscrowFactory = await ethers.getContractFactory("EscrowFactory");
    const escrowFactory = await EscrowFactory.deploy();
    await escrowFactory.waitForDeployment();
    console.log("EscrowFactory deployed to:", await escrowFactory.getAddress());

    // Deploy MockUSDC
    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const mockUSDC = await MockUSDC.deploy();
    await mockUSDC.waitForDeployment();
    console.log("MockUSDC deployed to:", await mockUSDC.getAddress());

    // Setup: Store MockUSDC address in EscrowFactory
    console.log("Setting up the contracts...");
    await escrowFactory.storeMockStablecoinAddress(await mockUSDC.getAddress());
    console.log("Mock USDC address stored in EscrowFactory");

    // Verify setup
    const storedAddress = await escrowFactory.getStablecoinAddress();
    console.log("Stored Mock Stablecoin Address:", storedAddress);

    if (storedAddress === await mockUSDC.getAddress()) {
        console.log("Setup completed successfully.");
    } else {
        console.error("Error: Stablecoin address mismatch.");
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });