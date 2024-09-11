const EscrowFactory = artifacts.require("EscrowFactory");
const MockUSDC = artifacts.require("MockUSDC");
const Escrow = artifacts.require('Escrow');
const { expectRevert } = require('@openzeppelin/test-helpers');

contract("EscrowFactory", (accounts) => {
    const [owner, member1, member2, member3] = accounts;

    it("should deploy an EscrowFactory contract", async () => {
        const factoryInstance = await EscrowFactory.new();
        assert(factoryInstance.address !== "0x0000000000000000000000000000000000000000");
    });

    it("should store the MockUSDC address in the factory", async () => {
        const factoryInstance = await EscrowFactory.new();
        const usdcInstance = await MockUSDC.new();

        await factoryInstance.storeMockStablecoinAddress(usdcInstance.address);
        const stablecoinAddress = await factoryInstance.getStablecoinAddress();

        assert.equal(stablecoinAddress, usdcInstance.address, "MockUSDC address should be stored");
    });

    it("should deploy an escrow for a calling member", async () => {
        const factoryInstance = await EscrowFactory.new();
        const usdcInstance = await MockUSDC.new();

        await factoryInstance.storeMockStablecoinAddress(usdcInstance.address);

        await factoryInstance.deployEscrow({ from: member1 });

        const escrowAddress = await factoryInstance.getEscrow(member1);
        assert(escrowAddress !== "0x0000000000000000000000000000000000000000", "Escrow should be deployed");
    });

    it("should revert for double deployment from the same member", async () => {
        const factoryInstance = await EscrowFactory.new();
        const usdcInstance = await MockUSDC.new();

        await factoryInstance.storeMockStablecoinAddress(usdcInstance.address);

        await factoryInstance.deployEscrow({ from: member1 });

        await expectRevert(
            factoryInstance.deployEscrow({ from: member1 }),
            'Escrow already deployed'
        );
    });

    it("should register when authorized Escrow Contract register with group members having no existing membership", async () => {
        const factoryInstance = await EscrowFactory.new();
        await factoryInstance.deployEscrow({ from: member1 });
        const m1DeployedEscrow = await factoryInstance.getEscrow(member1);

        const escrowInstance = await Escrow.at(m1DeployedEscrow);

        await escrowInstance.createGroup('TestGroup', [member1, member2, member3], { from: member1 });

        const member1Memberships = await factoryInstance.getUserEscrowMemberships(member1);
        assert.equal(member1Memberships.length, 0, "Member1 should have 0 membership");

        const member2Memberships = await factoryInstance.getUserEscrowMemberships(member2);
        assert.equal(member2Memberships.length, 1, "Member2 should have 1 membership");

        const member3Memberships = await factoryInstance.getUserEscrowMemberships(member3);
        assert.equal(member3Memberships.length, 1, "Member3 should have 1 membership");
    });

    it('should revert when non-Escrow Contract register membership', async () => {
        const factoryInstance = await EscrowFactory.new();

        await expectRevert(
            factoryInstance.registerGroupMembership(
                'TestGroup',
                [member1, member2],
                member1,
                { from: member1 }
            ),
            'You do not have the authorization to call this'
        );
    });

    it("should deregister when authorized Escrow Contract deregister with group members having no existing membership", async () => {
        const factoryInstance = await EscrowFactory.new();
        await factoryInstance.deployEscrow({ from: member1 });
        const m1DeployedEscrow = await factoryInstance.getEscrow(member1);

        const escrowInstance = await Escrow.at(m1DeployedEscrow);

        await escrowInstance.createGroup('TestGroup', [member1, member2, member3], { from: member1 });
        await escrowInstance.disbandGroup('TestGroup', { from: member1 });

        const member1Memberships = await factoryInstance.getUserEscrowMemberships(member1);
        assert.equal(member1Memberships.length, 0, "Member1 should have 0 membership");

        const member2Memberships = await factoryInstance.getUserEscrowMemberships(member2);
        assert.equal(member2Memberships.length, 0, "Member2 should have 0 membership");

        const member3Memberships = await factoryInstance.getUserEscrowMemberships(member3);
        assert.equal(member3Memberships.length, 0, "Member3 should have 0 membership");
    });

    it('should revert when non-Escrow Contract deregister membership', async () => {
        const factoryInstance = await EscrowFactory.new();

        await expectRevert(
            factoryInstance.deregisterGroupMembership(
                'TestGroup',
                [member1, member2],
                member1,
                { from: member1 }
            ),
            'You do not have the authorization to call this'
        );
    });
});
