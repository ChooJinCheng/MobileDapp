const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EscrowFactory", function () {
    let EscrowFactory, MockUSDC, Escrow, escrowFactory, mockUSDC;
    let owner, member1, member2, member3;

    beforeEach(async function () {
        [owner, member1, member2, member3] = await ethers.getSigners();

        EscrowFactory = await ethers.getContractFactory("EscrowFactory");
        MockUSDC = await ethers.getContractFactory("MockUSDC");
        Escrow = await ethers.getContractFactory("Escrow");

        escrowFactory = await EscrowFactory.deploy();
        await escrowFactory.waitForDeployment();

        mockUSDC = await MockUSDC.deploy();
        await escrowFactory.storeMockStablecoinAddress(await mockUSDC.getAddress());


    });

    describe("Deployment", function () {
        it("should deploy an EscrowFactory contract", async function () {
            const escrowFactoryAddress = await escrowFactory.getAddress();
            expect(escrowFactoryAddress).to.be.properAddress;
            expect(await ethers.provider.getCode(escrowFactoryAddress)).to.not.equal('0x');
        });

        it("should store the MockUSDC address in the factory", async function () {

            const stablecoinAddress = await escrowFactory.getStablecoinAddress();
            expect(stablecoinAddress).to.equal(await mockUSDC.getAddress());
        });

        it("should deploy an escrow for a calling member", async function () {
            await escrowFactory.connect(member1).deployEscrow();

            const escrowAddress = await escrowFactory.getEscrow(member1.address);
            expect(escrowAddress).to.not.equal(ethers.ZeroAddress);
        });

        it("should revert for double deployment from the same member", async function () {
            await escrowFactory.connect(member1).deployEscrow();

            await expect(escrowFactory.connect(member1).deployEscrow())
                .to.be.revertedWith('Escrow already deployed');
        });
    });

    describe("Membership Registeration", function () {
        it("should register when authorized Escrow Contract register with group members having no existing membership", async function () {
            await escrowFactory.connect(member1).deployEscrow();
            const m1DeployedEscrow = await escrowFactory.getEscrow(member1.address);

            const escrow = await Escrow.attach(m1DeployedEscrow);

            await escrow.connect(member1).createGroup('TestGroup', [member1.address, member2.address, member3.address]);

            const member1Memberships = await escrowFactory.getUserEscrowMemberships(member1.address);
            expect(member1Memberships.length).to.equal(0);

            const member2Memberships = await escrowFactory.getUserEscrowMemberships(member2.address);
            expect(member2Memberships.length).to.equal(1);

            const member3Memberships = await escrowFactory.getUserEscrowMemberships(member3.address);
            expect(member3Memberships.length).to.equal(1);
        });

        it('should revert when non-Escrow Contract register membership', async function () {
            await expect(escrowFactory.connect(member1).registerGroupMembership(
                'TestGroup',
                [member1.address, member2.address],
                member1.address
            )).to.be.revertedWith('You do not have the authorization to call this');
        });
    });

    describe("Membership De-registeration", function () {
        it("should deregister when authorized Escrow Contract deregister with group members having no existing membership", async function () {
            await escrowFactory.connect(member1).deployEscrow();
            const m1DeployedEscrow = await escrowFactory.getEscrow(member1.address);

            const escrow = await Escrow.attach(m1DeployedEscrow);

            await escrow.connect(member1).createGroup('TestGroup', [member1.address, member2.address, member3.address]);
            await escrow.connect(member1).disbandGroup('TestGroup');

            const member1Memberships = await escrowFactory.getUserEscrowMemberships(member1.address);
            expect(member1Memberships.length).to.equal(0);

            const member2Memberships = await escrowFactory.getUserEscrowMemberships(member2.address);
            expect(member2Memberships.length).to.equal(0);

            const member3Memberships = await escrowFactory.getUserEscrowMemberships(member3.address);
            expect(member3Memberships.length).to.equal(0);
        });

        it('should revert when non-Escrow Contract deregister membership', async function () {
            await expect(escrowFactory.connect(member1).deregisterGroupMembership(
                'TestGroup',
                [member1.address, member2.address],
                member1.address
            )).to.be.revertedWith('You do not have the authorization to call this');
        });
    });
});