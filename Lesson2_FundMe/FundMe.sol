// SPDX-License-Identifier: MIT

import "./PriceConsumerV3.sol";
import "./PriceConverter.sol";

pragma solidity ^0.8.0;

contract FundMe{

    using PriceConverter for uint256;

    uint256 public minimumUSD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUSD, "Not enough");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]=msg.value;
    }   

    function withdraw() public onlyOwner{
        for(uint i;i < funders.length;i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        // msg.sender = address, payable(msg.sender) = payable address

        //transfer 2300 gas throws error if fail
        //send 2300 gasreturns bool
        //call forward all gas or set fas, return bool
        //payable(msg.sender).transfer(address(this).balance);
        //bool sendSuccess;
        //require(sendSuccess = payable(msg.sender).send(address(this).balance),"Sending failed");
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner(){
        _; //first requiere than code
        require(msg.sender == owner, "Sender is not Owner");
        //_;to first the code then requiere
    }
}
