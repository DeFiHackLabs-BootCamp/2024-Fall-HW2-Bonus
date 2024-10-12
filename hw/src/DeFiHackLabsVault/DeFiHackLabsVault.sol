// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract DeFiHackLabsVault {
    uint256 public constant DURATION = 1 weeks;
    uint256 public constant MAXIMUMVOTES = 15;

    uint256 public immutable DEADLINE;
    address public immutable votingToken;

    struct Proposal {
        address receiver;
        bool executed;
        uint256 amount;
    }

    mapping(address account => bool) public isVoted;
    mapping(uint256 id => bool) public isExecuted;
    mapping(uint256 id => uint256 votes) public voteCounts;
    mapping(uint256 id => Proposal) public proposalInfo;

    uint256 public proposalId;
    uint256 public hightestVote;

    error InvalidMsgValue();
    error InvalidProposal();
    error NotDeFiHackLabsMember();
    error UnknownProposal();
    error FailToGrantFunds();
    error VotingNotClose();
    error AlreadyVoted();
    error AlreadyExecuted();
    error CannotExecuteProposal(uint256 id);

    constructor(address _votingToken) {
        DEADLINE = block.timestamp + DURATION;
        votingToken = _votingToken;
    }

    function createProposal(Proposal calldata proposal) external payable returns (uint256) {
        if (msg.value != 1 ether) revert InvalidMsgValue();
        if (proposal.receiver == address(0) || proposal.amount == 0 || proposal.executed == true) {
            revert InvalidProposal();
        }

        uint256 count = IERC1155(votingToken).balanceOf(msg.sender, 0) * 3;
        count += IERC1155(votingToken).balanceOf(msg.sender, 1);

        if (count == 0) revert NotDeFiHackLabsMember();
        if (count > hightestVote) hightestVote = count;

        voteCounts[proposalId] = count;
        proposalInfo[proposalId] = proposal;

        return proposalId++;
    }

    function vote(uint256 id) external {
        if (isVoted[msg.sender]) revert AlreadyVoted();
        uint256 votes = voteCounts[id];
        if (votes == 0) revert UnknownProposal();

        uint256 count = IERC1155(votingToken).balanceOf(msg.sender, 0) * 3;
        count += IERC1155(votingToken).balanceOf(msg.sender, 1);

        if (votes + count > hightestVote) {
            hightestVote = votes + count;
        }

        voteCounts[id] += count;
        isVoted[msg.sender] = true;
    }

    function execute(uint256 id) external {
        if (isExecuted[id]) revert AlreadyExecuted();
        uint256 votes = voteCounts[id];
        if (votes == 0) revert UnknownProposal();

        Proposal memory p = proposalInfo[id];
        uint256 amount = address(this).balance > p.amount ? p.amount : address(this).balance;

        if (votes >= MAXIMUMVOTES) {
            grantFunds(id, p.receiver, amount);
        } else if (votes == hightestVote) {
            if (block.timestamp < DEADLINE) revert VotingNotClose();
            grantFunds(id, p.receiver, amount);
        } else {
            revert CannotExecuteProposal(id);
        }
    }

    function grantFunds(uint256 id, address receiver, uint256 amount) private {
        (bool success,) = receiver.call{value: amount}("");
        if (!success) revert FailToGrantFunds();

        isExecuted[id] = true;
    }
}
