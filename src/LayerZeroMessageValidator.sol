// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IValidator} from "./ERC7579/IValidator.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

uint256 constant SIG_VALIDATION_FAILED_UINT = 1;
uint256 constant SIG_VALIDATION_SUCCESS_UINT = 0;
bytes4 constant ERC1271_INVALID = 0xffffffff;

contract LayerZeroMessageValidator is IValidator, OApp {
    type SrcEid is uint32;
    type Sender is address;
    type Spender is address;

    struct CrossChainCall {
        uint32 dstEid;
        address target;
        bytes calldata_;
        bytes option;
        MessagingFee fee;
    }

    mapping(address => mapping(SrcEid => mapping(Sender => mapping(Spender => bool)))) public originConfigs;
    mapping(address => mapping(bytes32 => bool)) public approvedOps;

    event ApproveOp(address indexed target, bytes32 calldataHash, bytes calldata_);

    constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(_owner) {}

    function setConfig(SrcEid srcEid, Sender sender, Spender[] calldata spenders, bool[] calldata approve) external {
        require(spenders.length == approve.length, "HarryPorter: invalid input length");

        for (uint256 i = 0; i < spenders.length; i++) {
            originConfigs[msg.sender][srcEid][sender][spenders[i]] = approve[i];
        }
    }

    /**
     * ERC-4337
     */
    function validateUserOp(PackedUserOperation calldata userOp, bytes32) external view returns (uint256) {
        // TODO: need more checks on gas

        if (!approvedOps[msg.sender][keccak256(userOp.callData)]) {
            return SIG_VALIDATION_FAILED_UINT;
        }

        return SIG_VALIDATION_SUCCESS_UINT;
    }

    // @dev This validator doesn't validate the signature so it always return a failed symbol
    function isValidSignatureWithSender(address, bytes32, bytes calldata) external pure returns (bytes4) {
        return ERC1271_INVALID;
    }

    /**
     * ERC-7579
     */
    function onInstall(bytes calldata data) external {}

    function onUninstall(bytes calldata data) external {}

    // @dev It's validator type (id 1)
    function isModuleType(uint256 moduleTypeId) external pure returns (bool) {
        return moduleTypeId == 1;
    }

    /**
     * LayerZero
     */
    function send(CrossChainCall[] calldata calls) external {
        for (uint256 i = 0; i < calls.length; i++) {
            _lzSend(
                calls[i].dstEid,
                abi.encode(calls[i].target, msg.sender, calls[i].calldata_),
                calls[i].option,
                calls[i].fee,
                payable(address(this))
            );
        }
    }

    function _lzReceive(Origin calldata origin, bytes32, bytes calldata _message, address, bytes calldata)
        internal
        override
    {
        (address target, address spender, bytes memory cd) = abi.decode(_message, (address, address, bytes));

        require(
            originConfigs[target][SrcEid.wrap(origin.srcEid)][Sender.wrap(address(uint160(uint256(origin.sender))))][Spender
                .wrap(spender)],
            "HarryPorter: invalid spender"
        );

        approvedOps[target][keccak256(cd)] = true;
    }

    function hashOrigin(Origin calldata origin) public pure returns (bytes32) {}
}
