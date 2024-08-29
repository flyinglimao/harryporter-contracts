// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModule} from "./IModule.sol";

interface IValidator is IModule {
    /**
     * User Operation struct
     * @param sender                - The sender account of this request.
     * @param nonce                 - Unique value the sender uses to verify it is not a replay.
     * @param initCode              - If set, the account contract will be created by this constructor/
     * @param callData              - The method call to execute on this account.
     * @param accountGasLimits      - Packed gas limits for validateUserOp and gas limit passed to the callData method call.
     * @param preVerificationGas    - Gas not calculated by the handleOps method, but added to the gas paid.
     *                                Covers batch overhead.
     * @param gasFees               - packed gas fields maxPriorityFeePerGas and maxFeePerGas - Same as EIP-1559 gas parameters.
     * @param paymasterAndData      - If set, this field holds the paymaster address, verification gas limit, postOp gas limit and paymaster-specific extra data
     *                                The paymaster will pay for the transaction instead of the sender.
     * @param signature             - Sender-verified signature over the entire request, the EntryPoint address and the chain ID.
     */
    struct PackedUserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        bytes32 accountGasLimits;
        uint256 preVerificationGas;
        bytes32 gasFees;
        bytes paymasterAndData;
        bytes signature;
    }

    /**
     * @dev Validates a UserOperation
     * @param userOp the ERC-4337 PackedUserOperation
     * @param userOpHash the hash of the ERC-4337 PackedUserOperation
     *
     * MUST validate that the signature is a valid signature of the userOpHash
     * SHOULD return ERC-4337's SIG_VALIDATION_FAILED (and not revert) on signature mismatch
     */
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) external returns (uint256);

    /**
     * @dev Validates a signature using ERC-1271
     * @param sender the address that sent the ERC-1271 request to the smart account
     * @param hash the hash of the ERC-1271 request
     * @param signature the signature of the ERC-1271 request
     *
     * MUST return the ERC-1271 `MAGIC_VALUE` if the signature is valid
     * MUST NOT modify state
     */
    function isValidSignatureWithSender(
        address sender,
        bytes32 hash,
        bytes calldata signature
    ) external view returns (bytes4);
}
