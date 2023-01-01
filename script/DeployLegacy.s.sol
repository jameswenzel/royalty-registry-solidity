// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseCreate2Script, console2 } from "create2-scripts/BaseCreate2Script.s.sol";
import { DeploySafe } from "create2-scripts/DeploySafe.s.sol";
import { DeployTimelockController } from "create2-scripts/DeployTimelockController.s.sol";
import { DeployProxyAdmin } from "create2-scripts/DeployProxyAdmin.s.sol";
import { DeployTransparentUpgradeableProxy } from "create2-scripts/DeployTransparentUpgradeableProxy.s.sol";
import { DeployImplementations } from "./DeployImplementations.s.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract DeployLegacy is BaseCreate2Script {
    function run() public {
        setUp();
        deploy();
    }

    function deploy() public returns (address) {
        vm.createSelectFork("mainnet");
        address registry = vm.envAddress("ROYALTY_ETH");
        address timelockOwner = Ownable(registry).owner();
        deploy(timelockOwner);

        vm.createSelectFork("polygon");
        registry = vm.envAddress("ROYALTY_POLY");
        timelockOwner = Ownable(registry).owner();
        deploy(timelockOwner);
    }

    function deploy(address timelockOwner) public returns (address) {
        (new DeployImplementations()).deploy();
        vm.setEnv("TIMELOCK_PROPOSERS", vm.toString(timelockOwner));
        (new DeployTimelockController()).deploy();
    }
}
