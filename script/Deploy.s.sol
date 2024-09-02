// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {LayerZeroMessageValidator} from "../src/LayerZeroMessageValidator.sol";

contract LayerZeroMessageValidatorScript is Script {
    LayerZeroMessageValidator public validator;

    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        validator = new LayerZeroMessageValidator(0x6EDCE65403992e310A62460808c4b910D972f10f, msg.sender);
        vm.stopBroadcast();
    }
}
