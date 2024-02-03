// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataLeasing {

    struct Lease {
        address owner;
        address tenant;
        uint256 leaseDuration;
        uint256 leaseStartTime;
        bool isActive;
    }

    mapping (bytes32 => Lease) public leases;

    event LeaseCreated(bytes32 indexed leaseId, address indexed owner, address indexed tenant, uint256 leaseDuration);
    event LeaseRevoked(bytes32 indexed leaseId);
    event DataDeleted(bytes32 indexed leaseId);

    modifier onlyOwner(bytes32 leaseId) {
        require(msg.sender == leases[leaseId].owner, "Not the owner");
        _;
    }

    modifier onlyTenant(bytes32 leaseId) {
        require(msg.sender == leases[leaseId].tenant, "Not the tenant");
        _;
    }

    modifier onlyActiveLease(bytes32 leaseId) {
        require(leases[leaseId].isActive, "Lease is not active");
        _;
    }

    function createLease(address tenant, uint256 leaseDuration) external {
        bytes32 leaseId = keccak256(abi.encodePacked(msg.sender, tenant, block.timestamp));
        leases[leaseId] = Lease(msg.sender, tenant, leaseDuration, block.timestamp, true);
        emit LeaseCreated(leaseId, msg.sender, tenant, leaseDuration);
    }

    function revokeLease(bytes32 leaseId) external onlyOwner(leaseId) onlyActiveLease(leaseId) {
        leases[leaseId].isActive = false;
        emit LeaseRevoked(leaseId);
    }

    function deleteData(bytes32 leaseId) external onlyTenant(leaseId) onlyActiveLease(leaseId) {
        require(block.timestamp >= leases[leaseId].leaseStartTime + leases[leaseId].leaseDuration, "Lease period not expired");
        leases[leaseId].isActive = false;
        emit DataDeleted(leaseId);
    }
}
