// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import "./interfaces/IGroupManager.sol";

contract GroupManager is IGroupManager {
    struct Group {
        address[] members;
        mapping(address => bool) isMember;
        mapping(address => uint256) balances;
    }

    mapping(string => Group) private groups;
    mapping(address => string[]) private membersGroupNames;
    uint8 private constant MAX_GROUP_SIZE = 10;

    function checkMembership(
        string memory groupName,
        address member
    ) public view {
        require(
            groups[groupName].isMember[member],
            "You are not a member of the group"
        );
    }

    function depositMemberFund(
        string memory groupName,
        address depositor,
        uint256 amount
    ) public override {
        require(amount > 0, "Amount must be positive");
        Group storage group = groups[groupName];
        group.balances[depositor] += amount;
    }

    function withdrawMemberFund(
        string memory groupName,
        address member,
        uint256 amount
    ) public override {
        require(amount > 0, "Amount must be positive");
        Group storage group = groups[groupName];
        require(
            group.balances[member] >= amount,
            "Insufficient funds to withdraw"
        );
        group.balances[member] -= amount;
    }

    function updateMembersBalance(
        string memory groupName,
        address payee,
        address[] memory payers,
        uint256 amount
    ) public override {
        require(
            groups[groupName].isMember[payee],
            "Payee is not a group member"
        );
        require(payers.length > 0, "No payers is given");
        require(amount > 0, "Amount must be positive");
        splitBalanceEqually(groupName, payee, payers, amount);
    }

    function splitBalanceEqually(
        string memory groupName,
        address payee,
        address[] memory payers,
        uint256 amount
    ) internal {
        Group storage group = groups[groupName];
        uint256 splitAmount = amount / (payers.length + 1);
        uint256 payeeAmount = amount - splitAmount;

        for (uint256 i = 0; i < payers.length; i++) {
            require(
                group.balances[payers[i]] >= splitAmount,
                "Member does not have sufficient balance to deduct"
            );
            group.balances[payers[i]] -= splitAmount;
        }
        group.balances[payee] += payeeAmount;
    }

    function createGroup(
        string memory groupName,
        address[] memory members,
        address owner
    ) public override {
        require(groups[groupName].members.length == 0, "Group already exist");
        require(
            membersGroupNames[owner].length < MAX_GROUP_SIZE,
            "You can only have max 10 groups"
        );
        Group storage newGroup = groups[groupName];

        for (uint i = 0; i < members.length; i++) {
            address member = members[i];
            if (!newGroup.isMember[member]) {
                newGroup.members.push(member);
                newGroup.isMember[member] = true;
                membersGroupNames[member].push(groupName);
            }
        }
    }

    function disbandGroup(
        string memory groupName
    )
        public
        override
        returns (address[] memory, address[] memory, uint256[] memory)
    {
        require(groups[groupName].members.length >= 2, "Group does not exist");
        address[] memory members = groups[groupName].members;
        uint256[] memory membersBalance = new uint256[](members.length);
        address[] memory noMembershipInEscrow = new address[](members.length);
        uint256 noMembershipInEscrowCount = 0;

        for (uint256 i = 0; i < members.length; i++) {
            address member = members[i];

            membersBalance[i] = groups[groupName].balances[member];

            for (uint256 j = 0; j < membersGroupNames[member].length; j++) {
                if (
                    keccak256(bytes(membersGroupNames[member][j])) ==
                    keccak256(bytes(groupName))
                ) {
                    membersGroupNames[member][j] = membersGroupNames[member][
                        membersGroupNames[member].length - 1
                    ];
                    membersGroupNames[member].pop();
                    break;
                }
            }

            if (membersGroupNames[member].length == 0) {
                noMembershipInEscrow[noMembershipInEscrowCount] = member;
                noMembershipInEscrowCount++;
            }

            delete groups[groupName].isMember[member];
            delete groups[groupName].balances[member];
        }

        // Adjust the size of noMembershipInEscrow to actual count
        assembly {
            mstore(noMembershipInEscrow, noMembershipInEscrowCount)
        }

        delete groups[groupName].members;
        delete groups[groupName];

        return (members, noMembershipInEscrow, membersBalance);
    }

    function addMember(
        string memory groupName,
        address member
    ) public override {
        require(
            !groups[groupName].isMember[member],
            "Member already exists in group"
        );
        groups[groupName].members.push(member);
        groups[groupName].isMember[member] = true;
        membersGroupNames[member].push(groupName);
    }

    function removeMember(
        string memory groupName,
        address member
    ) public override {
        require(groups[groupName].isMember[member], "Address is not a member");
        Group storage group = groups[groupName];

        uint length = group.members.length;
        for (uint i = 0; i < length; i++) {
            if (group.members[i] == member) {
                group.members[i] = group.members[length - 1];
                group.members.pop();
                break;
            }
        }

        for (uint256 i = 0; i < membersGroupNames[member].length; i++) {
            if (
                keccak256(bytes(membersGroupNames[member][i])) ==
                keccak256(bytes(groupName))
            ) {
                membersGroupNames[member][i] = membersGroupNames[member][
                    membersGroupNames[member].length - 1
                ];
                membersGroupNames[member].pop();
                break;
            }
        }
        group.isMember[member] = false;
    }

    function getAllMemberGroupNames(
        address member
    ) public view override returns (string[] memory) {
        return membersGroupNames[member];
    }

    function getGroupDetails(
        string memory groupName,
        address member
    ) public view override returns (uint256, uint256, address[] memory) {
        return (
            groups[groupName].members.length,
            groups[groupName].balances[member],
            groups[groupName].members
        );
    }

    function getGroupMembers(
        string memory groupName
    ) public view override returns (address[] memory) {
        return groups[groupName].members;
    }

    function getGroupMemberBalance(
        string memory groupName,
        address member
    ) public view override returns (uint256 balance) {
        return groups[groupName].balances[member];
    }
}
