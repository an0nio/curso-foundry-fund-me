//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {DeployFundMe} from "./DeployFundMe.s.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether; // Valor que se enviará al contrato FundMe

    // Función principal que se ejecuta para financiar el contrato FundMe
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    // Función para financiar el contrato FundMe con SEND_VALUE
    function fundFundMe(address mostRecentlyDeployed) public payable {
        vm.prank(msg.sender); // Simula que la transacción proviene de msg.sender
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
}


contract WithdrawFundMe is Script {
    // Función principal que se ejecuta para retirar los fondos del contrato FundMe
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    // Función para retirar los fondos del contrato FundMe
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.prank(msg.sender); // Simula que la transacción proviene de msg.sender
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        console.log("Withdrew funds");
    }
}