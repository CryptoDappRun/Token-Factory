// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20Burnable {
    using SafeMath for uint256;

    bool public isTradingActive;
    mapping(address => uint256) private _lastTradeTimestamp;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
        isTradingActive = true; // enable trading by default
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (isTradingActive) {
            require(_canTrade(msg.sender), "Trading cooldown period has not elapsed yet.");
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (isTradingActive) {
            require(_canTrade(sender), "Trading cooldown period has not elapsed yet.");
        }
        return super.transferFrom(sender, recipient, amount);
    }

    function setIsTradingActive(bool _isTradingActive) external onlyOwner {
        isTradingActive = _isTradingActive;
    }

    function _canTrade(address account) private view returns (bool) {
        uint256 lastTradeTime = _lastTradeTimestamp[account];
        if (lastTradeTime == 0) {
            // first trade - allowed
            return true;
        }
        uint256 timeElapsed = block.timestamp.sub(lastTradeTime);
        return timeElapsed >= 1 days; // trading cooldown of 1 day
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);
        if (isTradingActive) {
            _lastTradeTimestamp[from] = block.timestamp;
            _lastTradeTimestamp[to] = block.timestamp;
        }
    }
}