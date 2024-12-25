// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Call option
 * @author Draken
 * @notice 
 * Description:This is a call option
 */
contract Call is ERC20, Ownable {

    uint256 public strikePrice;
    uint256 public expiryDate;
    address public collateralAsset;

    mapping(address => uint256) public collateralBalances;

    event OptionMinted(address indexed account, uint256 amount);
    event OptionExercised(address indexed account, uint256 amount);
    event OptionExpired(address indexed account, uint256 amount);

    constructor(uint256 _strikePrice, uint256 _expiryDate, address _collateralAsset)
    ERC20("Call Option", "CALL")
    Ownable(msg.sender)
    {
        strikePrice = _strikePrice;
        expiryDate = _expiryDate;
        collateralAsset = _collateralAsset;
    }
    
    
    function mintOptionTokens(uint256 amount) public payable{
        require(msg.value == amount, "Collateral amount mismatch");
        collateralBalances[msg.sender] += msg.value;
        _mint(msg.sender, amount);
        emit OptionMinted(msg.sender, amount);
    }

    function exercise(uint256 amount) external {
        require(block.timestamp == expiryDate, "Can only exercise on expiry date");
        require(balanceOf(msg.sender) >= amount, "Insufficient option tokens");

        uint256 requiredPayment = (strikePrice * amount) / (10**decimals());
        require(IERC20(collateralAsset).transferFrom(msg.sender, address(this), requiredPayment), "Payment failed");

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit OptionExercised(msg.sender, amount);
    }

    function expireAndRedeem() external onlyOwner {
        require(block.timestamp > expiryDate, "Cannot redeem before expiry");
        uint256 remainingTokens = totalSupply();
        _burn(owner(), remainingTokens);
        for (uint256 i = 0; i < balanceOf(owner()); i++) {
            address user = owner();
            uint256 balance = collateralBalances[user];
            if (balance > 0) {
                payable(user).transfer(balance);
                collateralBalances[user] = 0;
            }
        }
        emit OptionExpired(owner(), remainingTokens);
    }
}