const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Escrow", function () {
    let Escrow, EscrowFactory, GroupManager, MockUSDC;
    let escrow, escrowFactory, groupManager, mockUSDC;
    let owner, member1, member2, member3, nonMember;

    beforeEach(async function () {
        [owner, member1, member2, member3, nonMember] = await ethers.getSigners();

        MockUSDC = await ethers.getContractFactory("MockUSDC");
        mockUSDC = await MockUSDC.deploy();
        await mockUSDC.waitForDeployment();

        EscrowFactory = await ethers.getContractFactory("EscrowFactory");
        escrowFactory = await EscrowFactory.deploy();
        await escrowFactory.waitForDeployment();

        await escrowFactory.storeMockStablecoinAddress(await mockUSDC.getAddress());

        await escrowFactory.connect(owner).deployEscrow();
        const escrowAddress = await escrowFactory.getEscrow(owner.address);

        Escrow = await ethers.getContractFactory("Escrow");
        escrow = await Escrow.attach(escrowAddress);
        await escrow.waitForDeployment();

        GroupManager = await ethers.getContractFactory("GroupManager");
        const groupManagerAddress = await escrow.getGroupManager()
        groupManager = await GroupManager.attach(groupManagerAddress);
        await groupManager.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should be deployed", async function () {
            const escrowAddress = await escrow.getAddress();

            expect(escrowAddress).to.be.properAddress;
            expect(await ethers.provider.getCode(escrowAddress)).to.not.equal('0x');
        });

        it("Should set the right owner", async function () {
            expect(await escrow.owner()).to.equal(owner.address);
        });

        it("Should set the right stablecoin", async function () {
            expect(await escrow.stablecoin()).to.equal(await mockUSDC.getAddress());
        });
    });

    describe("Group Management", function () {
        it("Should create a group", async function () {
            await expect(escrow.createGroup("TestGroup", [member1.address, member2.address]))
                .to.be.emit(escrow, "GroupCreated")
                .to.be.emit(escrowFactory, "EscrowRegistered");
        });

        it("Should revert when non-owner tries to create a group", async function () {
            await expect(escrow.connect(member1).createGroup("TestGroup", [member1.address, member2.address]))
                .to.be.revertedWithCustomError(escrow, "OwnableUnauthorizedAccount").withArgs(member1.address);
        });

        it("Should revert when trying to create a group with less than 2 members", async function () {
            await expect(escrow.createGroup("TestGroup", [member1.address]))
                .to.be.revertedWith("You must minimally have 2 members to create a group");
        });

        it("Should revert when trying to create a group with a invalid groupName", async function () {
            await expect(escrow.createGroup("", [member1.address]))
                .to.be.revertedWith("Group name is required");
        });

        it("Should add a member to a group", async function () {
            await escrow.createGroup("TestGroup", [member1.address, member2.address]);

            await expect(escrow.addMemberToGroup("TestGroup", member3.address)).to.be.emit(escrow, "MemberAdded");
        });

        it("Should revert when non-owner tries to add a member", async function () {
            await expect(escrow.connect(nonMember).addMemberToGroup("TestGroup", member3.address))
                .to.be.revertedWithCustomError(escrow, "OwnableUnauthorizedAccount").withArgs(nonMember);
        });

        it("Should revert when trying to add a member with a invalid groupName", async function () {
            await expect(escrow.addMemberToGroup("", member3.address))
                .to.be.revertedWith("Group name is required");
        });

        it("Should remove a member from a group", async function () {
            await escrow.createGroup("TestGroup", [member1.address, member2.address, member3.address]);

            await expect(escrow.removeMemberFromGroup("TestGroup", member2.address)).to.be.emit(escrow, "MemberRemoved");
        });

        it("Should revert when non-owner tries to remove a member", async function () {
            await expect(escrow.connect(nonMember).removeMemberFromGroup("TestGroup", member3.address))
                .to.be.revertedWithCustomError(escrow, "OwnableUnauthorizedAccount").withArgs(nonMember);
        });

        it("Should revert when trying to remove a member with a invalid groupName", async function () {
            await expect(escrow.removeMemberFromGroup("", member3.address))
                .to.be.revertedWith("Group name is required");
        });

        it("Should disband a group", async function () {
            await escrow.createGroup("TestGroup", [member1.address, member2.address]);
            await expect(escrow.disbandGroup("TestGroup"))
                .to.be.emit(escrow, "GroupDisbanded")
                .to.be.emit(escrowFactory, "EscrowDeregistered");
        });

        it("Should disband a group with refund", async function () {
            const escrowAddress = await escrow.getAddress();
            await mockUSDC.connect(member1).mintTokens(1000);
            await mockUSDC.connect(member1).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await escrow.createGroup("TestGroup", [member1.address, member2.address]);
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await expect(escrow.disbandGroup("TestGroup"))
                .to.be.emit(escrow, "GroupDisbanded")
                .to.be.emit(escrowFactory, "EscrowDeregistered");
        });

        it("Should disband a group with no EscrowDeregistered", async function () {
            await escrow.createGroup("TestGroup1", [owner.address, member1.address]);
            await escrow.createGroup("TestGroup2", [owner.address, member1.address]);
            await expect(escrow.disbandGroup("TestGroup1"))
                .to.be.emit(escrow, "GroupDisbanded")
                .to.be.not.emit(escrowFactory, "EscrowDeregistered");
        });

        it("Should revert when non-owner tries to disband a group", async function () {
            await expect(escrow.connect(nonMember).disbandGroup("TestGroup"))
                .to.be.revertedWithCustomError(escrow, "OwnableUnauthorizedAccount").withArgs(nonMember);
        });

        it("Should revert when trying to disband a group with a invalid groupName", async function () {
            await expect(escrow.disbandGroup(""))
                .to.be.revertedWith("Group name is required");
        });
    });

    describe("Transactions", function () {
        beforeEach(async function () {
            await escrow.createGroup("TestGroup", [member1.address, member2.address, member3.address]);
            const escrowAddress = await escrow.getAddress();
            await mockUSDC.connect(member1).mintTokens(1000);
            await mockUSDC.connect(member2).mintTokens(1000);
            await mockUSDC.connect(member3).mintTokens(1000);
            await mockUSDC.connect(member1).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await mockUSDC.connect(member2).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await mockUSDC.connect(member3).approve(escrowAddress, ethers.parseUnits("1000", 6));
        });

        it("Should deposit to group", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);

            const balance = await escrow.getGroupMemberBalance("TestGroup", member1.address);

            expect(balance).to.equal(1000000); // 100 * 10^4 (1000000 = 100.0000)
        });

        it("Should revert when non-member tries to deposit", async function () {
            await expect(escrow.connect(nonMember).depositToGroup("TestGroup", 100))
                .to.be.revertedWith("You are not a member of the group");
        });

        it("Should withdraw from group", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).withdrawFromGroup("TestGroup", 50);

            const balance = await escrow.getGroupMemberBalance("TestGroup", member1.address);
            expect(balance).to.equal(500000); // (100 - 50) * 10^4 (500000 = 50.0000)
        });

        it("Should revert when withdrawing more than balance", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await expect(escrow.connect(member1).withdrawFromGroup("TestGroup", 101))
                .to.be.revertedWith("Insufficient funds to withdraw");
        });

        it("Should initiate a transaction", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0, // TxnCategory.EXPENSE
                member2.address,
                [member1.address, member3.address],
                50,
                1,
                1,
                2023
            );
            const [payee, payers, value, status] = await escrow.getTransaction(1);
            expect(payee).to.equal(member2.address);
            expect(payers).to.include.members([member1.address, member3.address]);
            expect(value).to.equal(500000); // 50 * 10^4
            expect(status).to.equal(0); // TxnStatus.pending
        });

        it("Should approve a transaction partially", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await expect(escrow.connect(member1).approveTransaction("TestGroup", 1))
                .to.be.emit(escrow, "TransactionApproved");
            const [, , , , , , , requiredApproval] = await escrow.getTransaction(1);
            expect(requiredApproval).to.equal(1);
        });

        it("Should approve a transaction and executed it", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member3).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await escrow.connect(member1).approveTransaction("TestGroup", 1);
            await expect(escrow.connect(member3).approveTransaction("TestGroup", 1))
                .to.be.emit(escrow, "TransactionExecuted");
            const [, , , status] = await escrow.getTransaction(1);
            expect(status).to.equal(2); //TxnStatus.approved
        });

        it("Should decline a transaction", async function () {
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                50,
                1,
                1,
                2023
            );
            await expect(escrow.connect(member1).declineTransaction("TestGroup", 1))
                .to.be.emit(escrow, "TransactionDeclined");
            const [, , , status] = await escrow.getTransaction(1);
            expect(status).to.equal(1); // TxnStatus.declined
        });
    });

    describe("Edge Cases", function () {
        beforeEach(async function () {
            await escrow.createGroup("TestGroup", [member1.address, member2.address, member3.address]);
        });

        it("Should revert initiate transaction when no payers is given", async function () {
            await expect(escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member1.address,
                [],
                60,
                1,
                1,
                2023
            )).to.be.revertedWith("There must be one member involved");
        });

        it("Should revert initiate transaction when nonmember call", async function () {
            await expect(escrow.connect(nonMember).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            )).to.be.revertedWith("You are not a member of the group");
        });

        it("Should revert approve transaction when nonmember call", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(nonMember).approveTransaction("TestGroup", 1)).to.be.revertedWith("You are not a member of the group");
        });

        it("Should revert approve transaction when member approval is not required", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(member2).approveTransaction("TestGroup", 1)).to.be.revertedWith("You are not involved in this transaction");
        });

        it("Should revert approve transaction when transaction is invalid", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(member1).approveTransaction("TestGroup", 2)).to.be.revertedWith("Transaction does not exist");
        });

        it("Should revert approve transaction when member has already approved", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await escrow.connect(member1).approveTransaction("TestGroup", 1);

            await expect(escrow.connect(member1).approveTransaction("TestGroup", 1)).to.be.revertedWith("Transaction already approved by this member");
        });

        it("Should revert approve transaction when transaction is already executed", async function () {
            const escrowAddress = await escrow.getAddress();
            await mockUSDC.connect(member1).mintTokens(1000);
            await mockUSDC.connect(member3).mintTokens(1000);
            await mockUSDC.connect(member1).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await mockUSDC.connect(member3).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member3).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await escrow.connect(member1).approveTransaction("TestGroup", 1);
            await escrow.connect(member3).approveTransaction("TestGroup", 1);

            await expect(escrow.connect(member1).approveTransaction("TestGroup", 1)).to.be.revertedWith("Transaction has been processed");
        });

        it("Should revert decline transaction when nonmember call", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(nonMember).declineTransaction("TestGroup", 1)).to.be.revertedWith("You are not a member of the group");
        });

        it("Should revert decline transaction when member declination is not required", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(member2).declineTransaction("TestGroup", 1)).to.be.revertedWith("You are not involved in this transaction");
        });

        it("Should revert decline transaction when transaction is invalid", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );

            await expect(escrow.connect(member1).declineTransaction("TestGroup", 2)).to.be.revertedWith("Transaction does not exist");
        });

        it("Should revert decline transaction when member has already approved", async function () {
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await escrow.connect(member1).approveTransaction("TestGroup", 1);

            await expect(escrow.connect(member1).declineTransaction("TestGroup", 1)).to.be.revertedWith("Transaction already approved by this member");
        });

        it("Should revert decline transaction when transaction is already executed", async function () {
            const escrowAddress = await escrow.getAddress();
            await mockUSDC.connect(member1).mintTokens(1000);
            await mockUSDC.connect(member3).mintTokens(1000);
            await mockUSDC.connect(member1).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await mockUSDC.connect(member3).approve(escrowAddress, ethers.parseUnits("1000", 6));
            await escrow.connect(member1).depositToGroup("TestGroup", 100);
            await escrow.connect(member3).depositToGroup("TestGroup", 100);
            await escrow.connect(member1).initiateTransaction(
                "TestGroup",
                "Dinner",
                0,
                member2.address,
                [member1.address, member3.address],
                60,
                1,
                1,
                2023
            );
            await escrow.connect(member1).approveTransaction("TestGroup", 1);
            await escrow.connect(member3).approveTransaction("TestGroup", 1);

            await expect(escrow.connect(member1).declineTransaction("TestGroup", 1)).to.be.revertedWith("Transaction has been processed");
        });
    });
});