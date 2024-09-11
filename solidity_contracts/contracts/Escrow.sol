// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import "./interfaces/IEscrow.sol";
import "./GroupManager.sol";
import "./EscrowFactory.sol";
import "./enums/TransactionStatus.sol";
import "./enums/TransactionCategory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Escrow is IEscrow, Ownable, ReentrancyGuard {
    GroupManager private groupManager;
    EscrowFactory private escrowFactory;
    IERC20 public stablecoin;

    struct Transaction {
        address initiator;
        address payee;
        address[] payers;
        string groupName;
        string txnName;
        uint256 value;
        TxnCategory txnCategory;
        TxnStatus txnStatus;
        mapping(address => bool) approvals;
        uint256 numApprovals;
        uint256 requiredApprovals;
        uint32 packedDate;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;

    event Deposit(
        string indexed groupName,
        address indexed sender,
        uint256 amount
    );
    event Withdraw(
        string indexed groupName,
        address indexed sender,
        uint256 amount
    );
    event TransactionInitiated(
        string indexed groupName,
        uint8 day,
        uint8 indexed month,
        uint16 indexed year,
        string nonIndexedGroupName,
        TxnStatus txnStatus,
        uint256 transactionID,
        address initiator,
        address payee,
        address[] payers,
        string txnName,
        uint256 value,
        TxnCategory txnCategory,
        uint256 requiredApprovals,
        address contractAddress
    );
    event TransactionApproved(
        string indexed groupName,
        uint8 day,
        uint8 indexed month,
        uint16 indexed year,
        string nonIndexedGroupName,
        uint256 transactionId,
        address approver,
        address contractAddress
    );
    event TransactionDeclined(
        string indexed groupName,
        uint8 day,
        uint8 indexed month,
        uint16 indexed year,
        string nonIndexedGroupName,
        uint256 transactionId,
        TxnStatus txnStatus,
        address contractAddress
    );
    event TransactionExecuted(
        string indexed groupName,
        uint8 day,
        uint8 indexed month,
        uint16 indexed year,
        string nonIndexedGroupName,
        uint256 transactionId,
        TxnStatus txnStatus,
        address contractAddress
    );
    event GroupCreated(
        string groupName,
        address[] members,
        address indexed contractAddress
    );
    event GroupDisbanded(
        string groupName,
        address[] members,
        address indexed contractAddress
    );

    constructor(
        address _owner,
        address _factory,
        address _stablecoin
    ) Ownable(msg.sender) {
        transferOwnership(_owner);
        escrowFactory = EscrowFactory(_factory);
        groupManager = new GroupManager();
        stablecoin = IERC20(_stablecoin);
    }

    modifier validGroupName(string memory groupName) {
        require(bytes(groupName).length > 0, "Group name is required");
        _;
    }

    function depositToGroup(
        string memory groupName,
        uint256 amount
    ) public payable override validGroupName(groupName) {
        groupManager.checkMembership(groupName, msg.sender);
        uint256 weiAmount = convertToSmallestUnit(amount);
        groupManager.depositMemberFund(groupName, msg.sender, weiAmount);

        bool successFlag = stablecoin.transferFrom(
            msg.sender,
            address(this),
            weiAmount
        );
        require(successFlag, "Deposit failed");

        emit Deposit(groupName, msg.sender, weiAmount);
    }

    function withdrawFromGroup(
        string memory groupName,
        uint256 amount
    ) public override nonReentrant validGroupName(groupName) {
        groupManager.checkMembership(groupName, msg.sender);
        uint256 weiAmount = convertToSmallestUnit(amount);
        groupManager.withdrawMemberFund(groupName, msg.sender, weiAmount);

        bool successFlag = stablecoin.transfer(msg.sender, weiAmount);
        require(successFlag, "Withdrawal failed");

        emit Withdraw(groupName, msg.sender, weiAmount);
    }

    function initiateTransaction(
        string memory _groupName,
        string memory _txnName,
        TxnCategory _txnCategory,
        address _payee,
        address[] memory _payers,
        uint256 _value,
        uint8 day,
        uint8 month,
        uint16 year
    ) public override nonReentrant validGroupName(_groupName) {
        groupManager.checkMembership(_groupName, msg.sender);
        groupManager.checkMembership(_groupName, _payee);
        for (uint256 i = 0; i < _payers.length; i++) {
            groupManager.checkMembership(_groupName, _payers[i]);
        }
        require(_payers.length > 0, "There must be one member involved");

        uint256 weiAmount = convertToSmallestUnit(_value);
        transactionCount++;
        Transaction storage txn = transactions[transactionCount];
        txn.initiator = msg.sender;
        txn.groupName = _groupName;
        txn.txnName = _txnName;
        txn.payee = _payee;
        txn.payers = _payers;
        txn.value = weiAmount;
        txn.txnCategory = _txnCategory;
        txn.txnStatus = TxnStatus.pending;
        txn.numApprovals = 0;
        txn.requiredApprovals = _payers.length;
        txn.packedDate = packDate(day, month, year);

        emit TransactionInitiated(
            txn.groupName,
            day,
            month,
            year,
            txn.groupName,
            txn.txnStatus,
            transactionCount,
            txn.initiator,
            txn.payee,
            txn.payers,
            txn.txnName,
            txn.value,
            txn.txnCategory,
            txn.requiredApprovals,
            address(this)
        );
    }

    function approveTransaction(
        string memory groupName,
        uint256 _transactionId
    ) public override nonReentrant validGroupName(groupName) {
        groupManager.checkMembership(groupName, msg.sender);
        Transaction storage txn = transactions[_transactionId];
        require(txn.payee != address(0), "Transaction does not exist");
        require(
            txn.txnStatus == TxnStatus.pending,
            "Transaction has been processed"
        );
        require(
            isAddressInvolved(txn.payers),
            "You are not involved in this transaction"
        );
        require(
            txn.approvals[msg.sender] == false,
            "Transaction already approved by this member"
        );

        (uint8 day, uint8 month, uint16 year) = unpackDate(txn.packedDate);
        txn.approvals[msg.sender] = true;
        txn.numApprovals++;

        if (txn.numApprovals >= txn.requiredApprovals) {
            executeTransaction(_transactionId);
        } else {
            emit TransactionApproved(
                txn.groupName,
                day,
                month,
                year,
                txn.groupName,
                _transactionId,
                msg.sender,
                address(this)
            );
        }
    }

    function declineTransaction(
        string memory groupName,
        uint256 _transactionId
    ) public override nonReentrant validGroupName(groupName) {
        groupManager.checkMembership(groupName, msg.sender);
        Transaction storage txn = transactions[_transactionId];
        require(txn.payee != address(0), "Transaction does not exist");
        require(
            txn.txnStatus == TxnStatus.pending,
            "Transaction has been processed"
        );
        require(
            isAddressInvolved(txn.payers),
            "You are not involved in this transaction"
        );
        require(
            txn.approvals[msg.sender] == false,
            "Transaction already approved by this member"
        );

        (uint8 day, uint8 month, uint16 year) = unpackDate(txn.packedDate);
        txn.txnStatus = TxnStatus.declined;

        emit TransactionDeclined(
            txn.groupName,
            day,
            month,
            year,
            txn.groupName,
            _transactionId,
            txn.txnStatus,
            address(this)
        );
    }

    function executeTransaction(uint256 _transactionId) internal {
        Transaction storage txn = transactions[_transactionId];
        require(
            txn.txnStatus == TxnStatus.pending,
            "Transaction has been executed"
        );
        require(
            txn.numApprovals >= txn.requiredApprovals,
            "Not enough approvals"
        );

        groupManager.updateMembersBalance(
            txn.groupName,
            txn.payee,
            txn.payers,
            txn.value
        );
        (uint8 day, uint8 month, uint16 year) = unpackDate(txn.packedDate);
        txn.txnStatus = TxnStatus.approved;

        emit TransactionExecuted(
            txn.groupName,
            day,
            month,
            year,
            txn.groupName,
            _transactionId,
            txn.txnStatus,
            address(this)
        );
    }

    function isAddressInvolved(
        address[] memory payers
    ) internal view returns (bool) {
        for (uint256 i = 0; i < payers.length; i++) {
            if (payers[i] == msg.sender) return true;
        }
        return false;
    }

    function getTransaction(
        uint256 _transactionId
    )
        public
        view
        override
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
        )
    {
        Transaction storage txn = transactions[_transactionId];
        (uint8 day, uint8 month, uint16 year) = unpackDate(txn.packedDate);
        return (
            txn.payee,
            txn.payers,
            txn.value,
            txn.txnStatus,
            txn.txnCategory,
            txn.numApprovals,
            txn.requiredApprovals,
            day,
            month,
            year
        );
    }

    function createGroup(
        string memory groupName,
        address[] memory members
    ) public override onlyOwner validGroupName(groupName) {
        require(
            members.length >= 2,
            "You must minimally have 2 members to create a group"
        );
        groupManager.createGroup(groupName, members, msg.sender);
        escrowFactory.registerGroupMembership(groupName, members, msg.sender);
        emit GroupCreated(groupName, members, address(this));
    }

    function disbandGroup(
        string memory groupName
    ) public override onlyOwner nonReentrant validGroupName(groupName) {
        address[] memory members;
        address[] memory noMembershipInEscrow;
        uint256[] memory membersBalance;
        (members, noMembershipInEscrow, membersBalance) = groupManager
            .disbandGroup(groupName);

        for (uint256 i = 0; i < members.length; i++) {
            address member = members[i];
            uint256 memberBalance = membersBalance[i];
            if (memberBalance > 0) {
                bool successFlag = stablecoin.transfer(member, memberBalance);
                require(successFlag, "Balance send back failed");
            }
        }

        emit GroupDisbanded(groupName, members, address(this));
        if (noMembershipInEscrow.length != 0) {
            escrowFactory.deregisterGroupMembership(
                groupName,
                noMembershipInEscrow,
                msg.sender
            );
        }
    }

    function addMemberToGroup(
        string memory groupName,
        address member
    ) public override onlyOwner validGroupName(groupName) {
        groupManager.addMember(groupName, member);
    }

    function removeMemberFromGroup(
        string memory groupName,
        address member
    ) public override onlyOwner validGroupName(groupName) {
        groupManager.removeMember(groupName, member);
    }

    function getAllMemberGroupNames(
        address member
    ) public view override returns (string[] memory) {
        return groupManager.getAllMemberGroupNames(member);
    }

    function getGroupDetails(
        string memory groupName,
        address member
    ) public view override returns (uint256, uint256, address[] memory) {
        return groupManager.getGroupDetails(groupName, member);
    }

    function getGroupMembers(
        string memory groupName
    )
        public
        view
        override
        validGroupName(groupName)
        returns (address[] memory)
    {
        return groupManager.getGroupMembers(groupName);
    }

    function getGroupMemberBalance(
        string memory groupName,
        address member
    ) public view override validGroupName(groupName) returns (uint256) {
        return groupManager.getGroupMemberBalance(groupName, member);
    }

    function packDate(
        uint8 day,
        uint8 month,
        uint16 year
    ) internal pure returns (uint32) {
        return (uint32(year) << 16) | (uint32(month) << 8) | uint32(day);
    }

    function unpackDate(
        uint32 packedDate
    ) internal pure returns (uint8, uint8, uint16) {
        uint8 day = uint8(packedDate);
        uint8 month = uint8(packedDate >> 8);
        uint16 year = uint16(packedDate >> 16);

        return (day, month, year);
    }

    function convertToSmallestUnit(
        uint256 amount
    ) internal view returns (uint256) {
        return amount * (10 ** (getStablecoinDecimals() - 2));
    }

    function getStablecoinDecimals() internal view returns (uint8) {
        return ERC20(address(stablecoin)).decimals();
    }
}
