// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__WithdrawFailed();
error FundMe__InsufficientAmount();

/**
    @title A Contract for crowd funding
    @author Nikola Pavloivc
    @notice This contract is to demo a sample funding contract
    @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable iOwner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;
     
    modifier onlyOwner {
        if (msg.sender != iOwner) revert FundMe__NotOwner();
        _;
    }
    
    constructor(address priceFeedAddress) {
        iOwner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
        @notice This function funds the contract
        @dev This implements price feeds as our library
    */
    function fund() public payable {
        if(msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) revert FundMe__InsufficientAmount();
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    function withdraw() public payable onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        if(!callSuccess) revert FundMe__WithdrawFailed();
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't bes stored in memory

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = iOwner.call{value: address(this).balance}("");
        if(!callSuccess) revert FundMe__WithdrawFailed();
    }

    function getOwner() public view returns(address) {
        return iOwner;
    }

    function getFunders(uint256 index) public view returns(address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder) public view returns(uint256){
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return s_priceFeed;
    }
}