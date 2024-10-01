const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GroupManager", function () {
    let GroupManager;
    let groupManager;
    let owner, member1, member2, member3, nonMember;

    beforeEach(async function () {
        [owner, member1, member2, member3, nonMember] = await ethers.getSigners();

        GroupManager = await ethers.getContractFactory("GroupManager");
        groupManager = await GroupManager.deploy();
    });

    describe("Group Creation and Disbandment", function () {
        it("Should create a group", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);

            const [memberCount] = await groupManager.getGroupDetails("TestGroup", member1.address);
            expect(memberCount).to.equal(2);

            const groupNames = await groupManager.getAllMemberGroupNames(member1.address);
            expect(groupNames).to.include("TestGroup");
        });

        it("Should add a member to a group", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);
            await groupManager.addMember("TestGroup", member3.address);

            const members = await groupManager.getGroupMembers("TestGroup");
            expect(members).to.include(member3.address);

            const groupNames = await groupManager.getAllMemberGroupNames(member3.address);
            expect(groupNames).to.include("TestGroup");
        });

        it("Should remove a member from a group", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address, member3.address], owner.address);
            await groupManager.removeMember("TestGroup", member2.address);

            const members = await groupManager.getGroupMembers("TestGroup");
            expect(members).to.not.include(member2.address);

            const groupNames = await groupManager.getAllMemberGroupNames(member2.address);
            expect(groupNames).to.not.include("TestGroup");
        });

        it("Should disband a group", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);
            await groupManager.disbandGroup("TestGroup");

            expect(await groupManager.getGroupMembers("TestGroup")).to.be.empty;
        });

        it("Should revert when creating a group that already exists", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);

            await expect(groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address))
                .to.be.revertedWith("Group already exist");
        });

        it("Should revert when adding an existing member", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);

            await expect(groupManager.addMember("TestGroup", member1.address))
                .to.be.revertedWith("Member already exists in group");
        });

        it("Should revert when removing a non-existent member", async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);

            await expect(groupManager.removeMember("TestGroup", nonMember))
                .to.be.revertedWith("Address is not a member");
        });
    });

    describe("Fund Management", function () {
        beforeEach(async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address, member3.address], owner.address);
        });

        it("Should deposit member fund", async function () {
            await groupManager.depositMemberFund("TestGroup", member1.address, 100);

            const balance = await groupManager.getGroupMemberBalance("TestGroup", member1.address);

            expect(balance).to.equal(100);
        });

        it("Should withdraw member fund", async function () {
            await groupManager.depositMemberFund("TestGroup", member1.address, 100);
            await groupManager.withdrawMemberFund("TestGroup", member1.address, 50);

            const balance = await groupManager.getGroupMemberBalance("TestGroup", member1.address);

            expect(balance).to.equal(50);
        });

        it("Should revert when withdrawing more than balance", async function () {
            await groupManager.depositMemberFund("TestGroup", member1.address, 100);

            await expect(groupManager.withdrawMemberFund("TestGroup", member1.address, 150))
                .to.be.revertedWith("Insufficient funds to withdraw");
        });

        it("Should update members' balances and split amount equally after a transaction", async function () {
            await groupManager.depositMemberFund("TestGroup", member1.address, 100);
            await groupManager.depositMemberFund("TestGroup", member2.address, 100);
            await groupManager.updateMembersBalance("TestGroup", member3.address, [member1.address, member2.address], 60);

            expect(await groupManager.getGroupMemberBalance("TestGroup", member1.address)).to.equal(80);
            expect(await groupManager.getGroupMemberBalance("TestGroup", member2.address)).to.equal(80);
            expect(await groupManager.getGroupMemberBalance("TestGroup", member3.address)).to.equal(40);
        });

        it("Should revert when updating balance with insufficient funds", async function () {
            await groupManager.depositMemberFund("TestGroup", member1.address, 10);
            await groupManager.depositMemberFund("TestGroup", member2.address, 10);

            await expect(groupManager.updateMembersBalance("TestGroup", member3.address, [member1.address, member2.address], 60))
                .to.be.revertedWith("Member does not have sufficient balance to deduct");
        });
    });

    describe("Membership Checks", function () {
        beforeEach(async function () {
            await groupManager.createGroup("TestGroup", [member1.address, member2.address], owner.address);
        });

        it("Should confirm membership for existing member", async function () {
            await expect(groupManager.checkMembership("TestGroup", member1.address)).to.not.be.reverted;
        });

        it("Should revert for non-member", async function () {
            await expect(groupManager.checkMembership("TestGroup", nonMember))
                .to.be.revertedWith("You are not a member of the group");
        });
    });

    describe("Group Information Retrieval", function () {
        beforeEach(async function () {
            await groupManager.createGroup("Group1", [member1.address, member2.address], owner.address);
            await groupManager.createGroup("Group2", [member1.address, member3.address], owner.address);
        });

        it("Should get all member group names", async function () {
            const groupNames = await groupManager.getAllMemberGroupNames(member1.address);

            expect(groupNames).to.deep.equal(["Group1", "Group2"]);
        });

        it("Should get group details", async function () {
            const [memberCount, balance, members] = await groupManager.getGroupDetails("Group1", member1.address);

            expect(memberCount).to.equal(2);
            expect(balance).to.equal(0);
            expect(members).to.deep.equal([member1.address, member2.address]);
        });

        it("Should get group members", async function () {
            const members = await groupManager.getGroupMembers("Group1");

            expect(members).to.deep.equal([member1.address, member2.address]);
        });
    });

    describe("Edge Cases", function () {
        it("Should handle maximum group creation limit", async function () {
            for (let i = 0; i < 10; i++) {
                await groupManager.createGroup(`Group${i}`, [member1.address, member2.address, owner.address], owner.address);
            }

            await expect(groupManager.createGroup("Group11", [member1.address, member2.address, owner.address], owner.address))
                .to.be.revertedWith("You can only have max 10 groups");
        });

        it("Should handle zero amount deposits and withdrawals", async function () {
            await groupManager.createGroup("TestGroup", [member1.address], owner.address);

            await expect(groupManager.depositMemberFund("TestGroup", member1.address, 0))
                .to.be.revertedWith("Amount must be positive");
            await expect(groupManager.withdrawMemberFund("TestGroup", member1.address, 0))
                .to.be.revertedWith("Amount must be positive");
        });

        it("Should handle disbanding a non-existent group", async function () {
            await expect(groupManager.disbandGroup("NonExistentGroup"))
                .to.be.revertedWith("Group does not exist");
        });
    });
});