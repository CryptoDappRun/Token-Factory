pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20 {
    using SafeMath for uint256;
    address public  ContractOwner;
    uint256 public maxTransactionAmount; // The maximum amount of tokens that can be transferred in a single transaction
    mapping (address => bool) private _whitelistedAddresses; // A list of addresses that are exempt from the Anti-Whale feature
    
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {

        ContractOwner=msg.sender;
        _mint(msg.sender, initialSupply); // Mint the initial supply of tokens to the contract deployer
        
        maxTransactionAmount = totalSupply() / 100; // Set the initial maximum transaction amount to 1% of the total supply
    }

         modifier onlyOwner() {
        require(msg.sender == ContractOwner, "sender is not the owner");
        _;
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount <= maxTransactionAmount || _whitelistedAddresses[msg.sender], "Transfer amount exceeds the maximum transaction limit");
        
        _transfer(_msgSender(), recipient, amount);
        
        return true;
    }
    
    function setMaxTransactionAmount(uint256 amount) external onlyOwner {
        maxTransactionAmount = amount;
    }
    
    function whitelistAddress(address account) external onlyOwner {
        _whitelistedAddresses[account] = true;
    }
    
    function removeWhitelistedAddress(address account) external onlyOwner {
        _whitelistedAddresses[account] = false;
    }
}