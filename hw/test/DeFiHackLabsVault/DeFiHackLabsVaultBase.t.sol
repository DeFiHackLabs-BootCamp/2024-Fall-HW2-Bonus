// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {DeFiHackLabsToken} from "src/DeFiHackLabsVault/DeFiHackLabsToken.sol";
import {DeFiHackLabsVault} from "src/DeFiHackLabsVault/DeFiHackLabsVault.sol";

/**
 * DO NOT MODIFY THIS FILE, OR YOU WILL GET ZERO POINTS FROM THIS CHALLENGE
 */
contract DeFiHackLabsVaultBaseTest is Test {
    address internal wallet = makeAddr("SlowMistWallet");

    address internal sun = makeAddr("Sun");
    address internal alex = makeAddr("Alex");
    address internal alice = makeAddr("Alice");
    address internal louis = makeAddr("Louis");
    address internal bill = makeAddr("Bill");
    address internal player = makeAddr("player");

    DeFiHackLabsToken internal deFiHackLabsToken;
    DeFiHackLabsVault internal deFiHackLabsVault;

    uint256 private proposalId;

    modifier checkSolved() {
        voteByDeFiHackLabsMember();

        vm.startPrank(player, player);
        _;
        vm.stopPrank();

        if (address(deFiHackLabsVault).balance > 0) {
            vm.warp(block.timestamp + 1 weeks);
            deFiHackLabsVault.execute(proposalId);
        }

        _isSolved();
    }

    function setUp() public virtual {
        vm.startPrank(sun);
        deFiHackLabsToken = new DeFiHackLabsToken();
        // mint ERC1155 tokens to DeFiHackLabs' member, id 0 is for admin, and id 1 is for member
        deFiHackLabsToken.mint(sun, 0, 1, "");
        deFiHackLabsToken.mint(alex, 1, 1, "");
        deFiHackLabsToken.mint(louis, 1, 1, "");
        deFiHackLabsToken.mint(alice, 1, 1, "");
        deFiHackLabsToken.mint(bill, 1, 1, "");
        deFiHackLabsToken.mint(player, 1, 1, "");

        deFiHackLabsVault = new DeFiHackLabsVault(address(deFiHackLabsToken));
        vm.deal(address(deFiHackLabsVault), 5 ether);
        vm.stopPrank();

        vm.deal(address(sun), 1 ether);
        vm.deal(address(alex), 1 ether);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(louis), 1 ether);
        vm.deal(address(bill), 1 ether);
        vm.deal(address(player), 1 ether);
    }

    function voteByDeFiHackLabsMember() private {
        vm.startPrank(sun);
        DeFiHackLabsVault.Proposal memory proposal;
        proposal.receiver = wallet;
        proposal.amount = 2 ether;
        proposalId = deFiHackLabsVault.createProposal{value: 1 ether}(proposal);
        vm.stopPrank();

        vm.startPrank(alex);
        deFiHackLabsVault.vote(proposalId);
        vm.stopPrank();

        vm.startPrank(alice);
        deFiHackLabsVault.vote(proposalId);
        vm.stopPrank();

        vm.startPrank(louis);
        deFiHackLabsVault.vote(proposalId);
        vm.stopPrank();

        vm.startPrank(bill);
        deFiHackLabsVault.vote(proposalId);
        vm.stopPrank();
    }

    function _isSolved() private view {
        // Player cannot use other DeFiHackLabs members' ETH.
        assertEq(sun.balance, 0 ether);
        assertEq(alex.balance, 1 ether);
        assertEq(alice.balance, 1 ether);
        assertEq(louis.balance, 1 ether);
        assertEq(bill.balance, 1 ether);

        assertEq(address(deFiHackLabsVault).balance, 0, "vault still has ETH");
        assertEq(player.balance, 7 ether, "Not enough ETH in player account");
    }
}
