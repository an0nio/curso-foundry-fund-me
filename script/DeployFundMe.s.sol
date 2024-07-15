// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol"; 
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    
    function run() external returns (FundMe){
        //Tiene que ejecutarse antes de que llame a vm.startBroadcast() porque no es una transacción
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        //Después de llamar a vm.startBroadcast() sí se está ejecutando una transacción
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}