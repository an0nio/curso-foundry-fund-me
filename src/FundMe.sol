// Get founds from users
//Withdraw founds
// Set a minimum funding value in USF

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


error FundMe__NotOwner();

contract FundMe{
    //En este ejemplo se supone que estamos pagando en Wei. Recordar 1e18 Wei = 1 ETH
    using PriceConverter for uint256;

    // Las variables que empiezan por s_ son variables de estado
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    AggregatorV3Interface public s_priceFeed;



    uint public constant MINIMUM_USD = 5e18; // multiplica aquí porque no puede dividir entre 1e18 en require    
    address public immutable i_owner; 


    constructor(address priceFeed){
        i_owner = msg.sender; 
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    
    
    function fund() public payable{
        //Allow users to send money
        // Have a minumu $ sent
        require(msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "didnt send enouhgt money");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    //según esto saca todo el saldo del contrato. Recordar que address(this).balance es todo el saldo del contrato
    function withdraw() public onlyOwner{
        for (uint256 i = 0; i< s_funders.length; i++){
            s_addressToAmountFunded[s_funders[i]] = 0;
        }
        s_funders = new address[](0);

        //withdraw : 
        //transfer 
        //payable(msg.sender).transfer(address(this).balance); //msg.sender -> address ; payable(msg.sender) -> payable address

        //send
        bool sendSuccess =  payable(msg.sender).send(address(this).balance); 
        require (sendSuccess, "Send failed");

        //call
        // (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call {value :  address(this).balance }("");
        // require (callSuccess, "Call failed");

    }

    function cheaperWithdraw() public onlyOwner{
        uint256 fundersLenght = s_funders.length; //Solo lee desde memoria una vez
        for (uint256 i = 0; i < fundersLenght; i++){
            s_addressToAmountFunded[s_funders[i]] = 0;
        }
        s_funders = new address[](0);

        bool sendSuccess =  payable(msg.sender).send(address(this).balance); 
        require (sendSuccess, "Send failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner(){
        //require(msg.sender == i_owner, "Must be owner!");
        if(msg.sender != i_owner){ revert FundMe__NotOwner(); } //Aunque el código comentado arriba parece más legible, este ahorra más gas
        _;
    }

     //What happends if someone send this contract ETH without calling the fund function?
    //recieve()
    //fallback()
  


    receive() external payable {
        fund();
    }

     fallback() external payable { 
        fund();
     }

     /**
      * View / Pure functions (Getter functions)
      */

     function getAddresToAmountFunded(address funder) external view returns(uint256){
         return s_addressToAmountFunded[funder];
     }

     function getFunder(uint256 index) external view returns(address){
         return s_funders[index];
     }

     function getOwner() external view returns(address){
         return i_owner;
     }


}

