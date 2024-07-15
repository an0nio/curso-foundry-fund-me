// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

//Este código no despliega ningún contrato, solo interactúa con contratos ya desplegados

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); 
    uint256 expectedPriceFeedVersion = 4;
    uint256 expectedMinimumValue = 5 * 10 ** 18;
    uint256 SEND_VALUE = 0.1 ether; 
    uint256 STARTING_BALANCE = 10 ether; 

    // Configuración inicial que despliega el contrato FundMe y asigna 10 ETHs a USER
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); 
    }

    // Prueba que el usuario del contrato FundMe puede interactuar con el contrato FundFundMe
    function testUserCanFundInteractions() public {
        // Arrange para la financiación
        FundFundMe fundFundMe = new FundFundMe();
        // Act para la financiación
        vm.prank(USER); // Simula que la transacción proviene de USER
        fundFundMe.fundFundMe(address(fundMe)); // Financiar 
        // Assert para la financiación
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); // Verifica que USER está registrado como un financiador

        // Arrange para el retiro de fondos
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // Act para el retiro de fondos
        vm.prank(msg.sender); // Establece que la próxima operación se ejecute como si fuera iniciada por la cuenta que ejecuta este test.
        withdrawFundMe.withdrawFundMe(address(fundMe)); 
        // Assert para el retiro de fondos
        assertEq(address(fundMe).balance, 0); 
    }
}