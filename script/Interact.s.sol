// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLength();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE =
        hex"70c9b519302dcb430e0e0358dec645d45336376c86ce8084ebfc3e78bbd6e22367fb4fc3ec8246e000ef2726d4a9bcd115ebf95890036aa3ec62f2f831c532c31c";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
        //note - when using openzeppelin functions and order functions the order is r,s,v
        //when using assembly or unpacking from a signature the order is v,r,s
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(mostRecentlyDeployed);
    }
}

//note without --broadcast in the cmd, it will only simulate sending the transaction on the blockchain without actually sending it
//note when running script use the contract name rather than mixing it up with a function name
