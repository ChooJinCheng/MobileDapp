const { ethers } = require("hardhat");

async function main() {
    /* const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const parameter = "0x70997970c51812dc3a010c7d01b50e0d17dc79c8";

    const contract = await ethers.getContractAt("EscrowFactory", contractAddress);
    const result = await contract.getEscrow(parameter);
    console.log("Result:", result); */

    const mockUsdcAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const mockUSDCContract = await ethers.getContractAt("MockUSDC", mockUsdcAddress);

    const signers = await ethers.getSigners();
    const signer = signers[1];
    const amountToMint = ethers.toBigInt(100);

    const tx = await mockUSDCContract.connect(signer).mintTokens(amountToMint);
    await tx.wait();

    console.log("Tokens minted successfully!");

    const balanceAfterMint = await mockUSDCContract.balanceOf(signer.address);
    console.log("Address of signer:", signer.address);
    console.log("Balance after minting:", ethers.toNumber(balanceAfterMint));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });