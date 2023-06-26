pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 public taxRate; // The percentage of tokens to be deducted as tax
    address public taxCollector; // The address that will receive the collected tax
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        taxRate = 1; // Set the initial tax rate to 1%
        taxCollector = msg.sender; // Use the contract deployer's address as the initial tax collector
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 taxAmount = amount * taxRate / 100; // Calculate the amount of tokens to be deducted as tax
        uint256 amountAfterTax = amount - taxAmount; // Calculate the amount of tokens to be transferred after tax
        
        _transfer(_msgSender(), taxCollector, taxAmount); // Transfer the collected tax to the tax collector's address
        _transfer(_msgSender(), recipient, amountAfterTax); // Transfer the remaining tokens to the recipient's address
        
        return true;
    }
}