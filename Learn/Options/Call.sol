// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Call option
 * @author Draken
 * @notice This is a call option
 */
contract Call is ERC20, Ownable {
    uint256 public strikePrice;
    uint256 public expiryDate;
    IERC20 public paymentToken;
    IERC20 public collateralAsset;

    mapping(address => uint256) public collateralBalances;

    event OptionMinted(address indexed account, uint256 amount);
    event OptionExercised(address indexed account, uint256 amount);
    event OptionExpired(address indexed account, uint256 amount);

    constructor(
        uint256 _strikePrice,
        uint256 _expiryDate,
        address _paymentToken,
        address _collateralAsset
    ) ERC20("Call Option", "CALL") Ownable(msg.sender) {
        require(
            _expiryDate > block.timestamp,
            "Expiry date must be in the future"
        );
        require(_paymentToken != address(0), "Invalid payment token address");
        require(
            _collateralAsset != address(0),
            "Invalid collateral asset address"
        );

        strikePrice = _strikePrice;
        expiryDate = _expiryDate;
        paymentToken = IERC20(_paymentToken);
        collateralAsset = IERC20(_collateralAsset);
    }

    function mintOptionTokens(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value >= amount, "Collateral amount mismatch");

        require(
            collateralAsset.transferFrom(msg.sender, address(this), amount),
            "Collateral transfer failed"
        );

        collateralBalances[msg.sender] += amount;
        _mint(msg.sender, amount);
        emit OptionMinted(msg.sender, amount);
    }

    function exercise(uint256 amount) external {
        require(block.timestamp <= expiryDate, "Option has expired");
        require(balanceOf(msg.sender) >= amount, "Insufficient option tokens");

        uint256 requiredPayment = (strikePrice * amount) / (10 ** decimals());

        require(
            paymentToken.transferFrom(
                msg.sender,
                address(this),
                requiredPayment
            ),
            "Payment transfer failed"
        );

        require(
            collateralAsset.transfer(msg.sender, amount),
            "Collateral transfer failed"
        );

        _burn(msg.sender, amount);
        emit OptionExercised(msg.sender, amount);
    }

    function expireAndRedeem() external onlyOwner {
        require(block.timestamp > expiryDate, "Cannot redeem before expiry");

        uint256 remainingTokens = totalSupply();

        if (remainingTokens > 0) {
            _burn(owner(), remainingTokens);
        }

        uint256 remainingCollateral = collateralBalances[owner()];
        if (remainingCollateral > 0) {
            payable(owner()).transfer(remainingCollateral);
            collateralBalances[owner()] = 0;
        }

        emit OptionExpired(owner(), remainingTokens);
    }
}
