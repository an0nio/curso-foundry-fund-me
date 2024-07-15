// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";






contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("user"); // es un cheatcode para crear una dirección de usuario

    function setUp() external{
        // fundMe = new FundMe(); 1º versión
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); 2º versión
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 * 10e18); // Hacemos que el usuario tenga 10 ETHs
    }

    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(),5 * 10 ** 18);        
    }

    function testOwnerIsMsgSender() public{
        assertEq(fundMe.getOwner(),msg.sender);
    }
 
    function testPriceFeedVersionIsAccurate() public{
        assertEq(fundMe.getVersion(),4);
    }

    function testPriceEth() public {
        uint256 ethPrice = PriceConverter.getPrice(fundMe.s_priceFeed());
        console.log("Price of ETH in terms of USD with 18 decimals precision: ", ethPrice);
    }

    function testFoundFailsWithoutEnoughtEHT() public {
        vm.expectRevert(); // La siguiente transacción debe revertir. En caso contrario falla el test
        fundMe.fund(); // Envíamos 0 ETHs
    }

     modifier funded(){
        vm.prank(USER); 
        fundMe.fund{value: 0.1 * 1e18}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded{
        assertEq(fundMe.getAddresToAmountFunded(USER), 0.1 * 10 ** 18);
    }

    function testAddsFundersToArrayOfFunders() public {
        // Esto en el test funcionará simpre, ya que siempre se llama a la función setUp antes de cada test
        vm.prank(USER); // Hacemos que el usuario sea USER
        fundMe.fund{value: 0.1 * 10e18}(); //Envíamos 0.1 ETHs
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public{
        vm.expectRevert(); // La siguiente transacción debe revertir. En caso contrario falla el test
        vm.prank(USER);  // Esto no es una transacción
        fundMe.withdraw(); // Solo el owner puede retirar fondos
    }   

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = address(this).balance;
        uint256 startingFoundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testWithDrawFromMultipleFunders() public {
        //Arrange
        uint160 numberOfFunders = 10;
        for (uint160 i = 0; i < numberOfFunders; i++){
            hoax(address(i), 10e18);
            fundMe.fund{value: 0.1 * 1e18}();
        }

        uint256 startingOwnerBalance = address(this).balance;
        uint256 startingFoundMeBalance = address(fundMe).balance;


        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert   
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFoundMeBalance);

    }

    function testWithDrawFromMultipleFundersCheaper() public {
        //Arrange
        uint160 numberOfFunders = 10;
        for (uint160 i = 0; i < numberOfFunders; i++){
            hoax(address(i), 10e18);
            fundMe.fund{value: 0.1 * 1e18}();
        }

        uint256 startingOwnerBalance = address(this).balance;
        uint256 startingFoundMeBalance = address(fundMe).balance;


        //Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        //Assert   
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFoundMeBalance);

    }
}