// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

interface IGroupManager {
    function checkMembership(string memory groupName, address member) external view;
    function depositMemberFund(string memory groupName, address depositor, uint256 amount) external;
    function withdrawMemberFund(string memory groupName, address member, uint256 amount) external;
    function updateMembersBalance(string memory groupName, address initiator, address[] memory involvedParties, uint256 amount) external;
    function createGroup(string memory groupName, address[] memory members, address owner) external;
    function disbandGroup(string memory groupName) external returns(address[] memory, address[] memory, uint256 [] memory);
    function addMember(string memory groupName, address member) external;
    function removeMember(string memory groupName, address member) external;
    function getAllMemberGroupNames(address member) external view returns (string[] memory);
    function getGroupDetails(string memory groupName, address member) external view returns(uint256, uint256, address[] memory);
    function getGroupMembers(string memory groupName) external view returns (address[] memory);
    function getGroupMemberBalance(string memory groupName, address member) external view returns (uint256 balance);
}