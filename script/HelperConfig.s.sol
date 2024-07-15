// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MocsV3Aggreggator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig{
        address priceFeed; //ETH/USD price feed address
    } 

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 3300e8;

    constructor(){
        //Cada red tiene su chainid. Por ejemplo, en Ethereum Mainnet el chainid es 1
        // Podemos consultar más sobre los chainid en https://chainlist.org/
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        } else{
            activeNetworkConfig = getAnvilEthConfig();
        }
    }


    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        //price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    //Devuelve ó crea un nuevo price feed address
    function getAnvilEthConfig() public returns(NetworkConfig memory){
        // Si ya existe un price feed address, lo devuelve
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        // Si no existe un price feed address, crea uno nuevo
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }

}

