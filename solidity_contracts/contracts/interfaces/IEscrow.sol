// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;
import "../GroupManager.sol";
import "../enums/TransactionCategory.sol";
import "../enums/TransactionStatus.sol";

interface IEscrow {
    function depositToGroup(
        string memory groupName,
        uint256 amount
    ) external payable;
    function withdrawFromGroup(
        string memory groupName,
        uint256 amount
    ) external;
    function initiateTransaction(
        string memory _groupName,
        string memory _txnName,
        TxnCategory _txnCategory,
        address _payee,
        address[] memory _txnParties,
        uint256 _value,
        uint8 day,
        uint8 month,
        uint16 year
    ) external;
    function approveTransaction(
        string memory groupName,
        uint256 _transactionId
    ) external;
    function declineTransaction(
        string memory groupName,
        uint256 _transactionId
    ) external;
    function getTransaction(
        uint256 transactionId
    )
        external
        view
        returns (
            address,
            address[] memory,
            uint256,
            TxnStatus,
            TxnCategory,
            uint256,
            uint256,
            uint8,
            uint8,
            uint16
        );
    function createGroup(
        string memory groupName,
        address[] memory members
    ) external;
    function disbandGroup(string memory groupName) external;
    function addMemberToGroup(string memory groupName, address member) external;
    function removeMemberFromGroup(
        string memory groupName,
        address member
    ) external;
    function getAllMemberGroupNames(
        address member
    ) external view returns (string[] memory);
    function getGroupDetails(
        string memory groupName,
        address member
    ) external view returns (uint256, uint256, address[] memory);
    function getGroupMembers(
        string memory groupName
    ) external view returns (address[] memory);
    function getGroupMemberBalance(
        string memory groupName,
        address member
    ) external view returns (uint256 balance);
    function getGroupManager() external view returns (address);
}
