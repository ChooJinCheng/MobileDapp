// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;
import "./Escrow.sol";

contract EscrowFactory {
    mapping(address => address) private userToEscrow;
    // Mapping from user address to list of escrowContract user has membership in
    mapping(address => address[]) private userToEscrowMembership;
    // Mapping from user address to a mapping of contract addresses they are members of (simulating a set)
    mapping(address => mapping(address => bool))
        private userEscrowMembershipExists;
    address mockStablecoin;

    event EscrowDeployed(address indexed user, address escrow);
    event EscrowRegistered(
        string groupName,
        address deployedEscrow,
        address indexed member
    );
    event EscrowDeregistered(
        string groupName,
        address deployedEscrow,
        address indexed member
    );

    function deployEscrow() public {
        require(
            userToEscrow[msg.sender] == address(0),
            "Escrow already deployed"
        );
        // console.log("Message Requester %s", msg.sender);
        address escrowDeployedAddress = address(
            new Escrow(msg.sender, address(this), mockStablecoin)
        );
        // console.log("Newly created escrow address: ", escrowDeployedAddress);
        userToEscrow[msg.sender] = escrowDeployedAddress;
        emit EscrowDeployed(msg.sender, escrowDeployedAddress);
    }

    function storeMockStablecoinAddress(address deployedAddress) public {
        mockStablecoin = deployedAddress;
    }

    function registerGroupMembership(
        string memory groupName,
        address[] memory members,
        address owner
    ) external {
        require(
            msg.sender == userToEscrow[owner],
            "You do not have the authorization to call this"
        );
        address escrowAddress = msg.sender;
        for (uint256 i = 0; i < members.length; i++) {
            address member = members[i];
            if (
                !userEscrowMembershipExists[member][escrowAddress] &&
                member != owner
            ) {
                userToEscrowMembership[member].push(escrowAddress);
                userEscrowMembershipExists[member][escrowAddress] = true;
                emit EscrowRegistered(groupName, escrowAddress, member);
            }
        }
    }

    function deregisterGroupMembership(
        string memory groupName,
        address[] memory members,
        address owner
    ) external {
        require(
            msg.sender == userToEscrow[owner],
            "You do not have the authorization to call this"
        );
        address escrowAddress = msg.sender;
        for (uint256 i = 0; i < members.length; i++) {
            address member = members[i];
            if (
                userEscrowMembershipExists[member][escrowAddress] &&
                member != owner
            ) {
                for (
                    uint256 escrow = 0;
                    escrow < userToEscrowMembership[member].length;
                    escrow++
                ) {
                    if (
                        userToEscrowMembership[member][escrow] == escrowAddress
                    ) {
                        userToEscrowMembership[member][
                            escrow
                        ] = userToEscrowMembership[member][
                            userToEscrowMembership[member].length - 1
                        ];
                        userToEscrowMembership[member].pop();
                        break;
                    }
                }
                userEscrowMembershipExists[member][escrowAddress] = false;
                emit EscrowDeregistered(groupName, escrowAddress, member);
            }
        }
    }

    function getEscrow(address user) public view returns (address) {
        return userToEscrow[user];
    }

    function getUserEscrowMemberships(
        address user
    ) public view returns (address[] memory) {
        return userToEscrowMembership[user];
    }

    function getStablecoinAddress() public view returns (address) {
        return mockStablecoin;
    }
}
