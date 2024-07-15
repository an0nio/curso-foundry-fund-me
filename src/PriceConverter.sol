// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
   function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        (, int256 price,,,) = priceFeed.latestRoundData(); 
        // Price of ETH in terms of USD wiht 18 decimals precision
        return uint256(price * 1e10); // chainlink devuelve precios con 8 decimales de precisión y queremos convertirlo a 18 decimales
    }

    // 1000000000
    // call it get fiatConversionRate, since it assumes something about decimals
    // It wouldn't work for every aggregator
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

   
}