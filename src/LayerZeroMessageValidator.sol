// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IValidator} from "./ERC7579/IValidator.sol";

contract LayerZeroMessageValidator is IValidator {
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) external returns (uint256) {}

    // @dev This validator doesn't validate the signature
    function isValidSignatureWithSender(
        address,
        bytes32,
        bytes calldata
    ) external pure returns (bytes4) {
        return 0x00000000;
    }

    function onInstall(bytes calldata data) external {}

    function onUninstall(bytes calldata data) external {}

    // @dev It's validator type (id 1)
    function isModuleType(uint256 moduleTypeId) external pure returns (bool) {
        return moduleTypeId == 1;
    }
}
