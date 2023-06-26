// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC20Pausable, AccessControl {
    bytes32 public constant BLACKLISTED_ROLE = keccak256("BLACKLISTED_ROLE");
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    bool public isContractActive;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(isContractActive, "Contract is inactive.");
        require(!hasRole(BLACKLISTED_ROLE, _msgSender()), "Sender is blacklisted.");
        require(hasRole(WHITELISTED_ROLE, _msgSender()) || hasRole(WHITELISTED_ROLE, recipient), "Recipient is not whitelisted.");

        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(isContractActive, "Contract is inactive.");
        require(!hasRole(BLACKLISTED_ROLE, sender), "Sender is blacklisted.");
        require(hasRole(WHITELISTED_ROLE, sender) || hasRole(WHITELISTED_ROLE, recipient), "Recipient is not whitelisted.");

        return super.transferFrom(sender, recipient, amount);
    }

    function addBlacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BLACKLISTED_ROLE, account);
    }

    function removeBlacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(BLACKLISTED_ROLE, account);
    }

    function addWhitelist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(WHITELISTED_ROLE, account);
    }

    function removeWhitelist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(WHITELISTED_ROLE, account);
    }

    function setIsContractActive(bool _isContractActive) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isContractActive = _isContractActive;
    }
}
