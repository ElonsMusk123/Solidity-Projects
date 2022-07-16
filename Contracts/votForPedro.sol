// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
/// @title Voting with delegation.

contract Ballot {
    // this declares a new complex type which will
    // be used for variables later
    // It will represent a single voter

    struct Voter {
        uint weight; // voting weight accumulated through governance
        bool voted; // if true, address has already voted
        address delegate; // address delegated to
        uint vote; // index of voted proposal
    }

    struct Proposal {
        bytes32 name; //max 32 byte name
        uint VoteCount; // total votes accumulated
    }

    address public chairperson;

    // This declares a state var that stores a 'Voter' struct
    // for each possible address
    mapping (address => Voter) public voters;

    // dynamically sized array of 'Proposal' structs
    Proposal[] public proposals;

    // create new ballot to choose one of 'proposalNames'
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposalNames, create a new
        // proposal object and add to end of the array
        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temp object and
            // and proposals.push(...) appends to end of 'proposals'
            proposals.push(Proposal({
                name: ProposalNames[i],
                VoteCount: 0;
            }))

        }
    }

    // Give voter right to vote on Ballot
    // only callable by 'chairperson'

    function giveRightToVote(address voter) external {
        // if first arg of'require' evals to false,
        // execution terminates and all changes to state and balance
        // are reverted. In older EVM clients this would consume all gas
        // but not anymore. It's often a good idea to call 'require'
        // to check if functions are stored correctly.
        // As a second arg, you can also provide and and print an explanation
        // for what went wrong.
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote"
        );
        require(
            !voters[voter].voted,
            "This address already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

// Delegate your vote to the voter 'to'
function delegate(address to) external {
    //assigns reference
    Voter storage sender = voters[msg.sender];
    require(sender.weight != 0, "You have no rights here.")
    require(!sender.voted, "You already voted for Pedro. Thank you kindly.")

    require(to != msg.sender, "Self-delegation is disallowed.")

    // Forward delegation as long as "to" is also delegated
    // As a generality, these long loops are dangerous - if they
    // run too long, they might require more gas than is available
    // in a block.
    // In this case, the delegation will not be executed,
    // but in other situations, similar loops might cause a stuck contract
    while (voters[to].delegate != address(0)) {
        to = voters[to].delegate;

        // Found a loop in delegation, not allowed.
        require(to != msg.sender, "Found loop in delegation.");
    }

    Voter storage delegate_ = voters[to];

    // Voters cannot delegate to accounts that can't vote
    require(delegate_.weight >= 1);

    //Since 'sender' is a reference this mods 'voters[msg.sender]'
    sender.voted = true;
    sender.delegate = to;

    if (delegate_.voted) {
        // if voted, directly add to # of voters
        proposals[delegate.vote].voteCounte += sender.weight;
    } else {
        // if the delegate did nto vote yet add to her weight
        delegate_.weight += sneder.weight
    }
}

/// Give your vote (inc votes delegate to you)
/// to proposal 'proposals[proposal].name'
function vote(uint proposal) external {
    Voter storage sender = voters[msg.sender];
    require(sender.weight != 0, "You have no rights here.")
    require(!sender.voted, "You already voted for Pedro. Thank you kindly.");
    sender.voted = true;
    sender.vote = proposal;

    // If proposal is out of the range of the array,
    // throw and revert changes
    proposals[proposal].voteCount += sender.weight;
}

///@dev Computes winning proposal taking into accounts all prev voters
function winningProposal() public view
    returns (uint winningProposal_)

{
    uint winningVoteCount = 0;
    for (uint p = 0; p < proposals.length; p++) {
        if (proposals[p].voteCount > winningVotecount) {
            winningVoteCount = proposals[p].voteCount;
            winningProposal_ = p;
        }
    }
}

// Calls winningProposal() to get index of winner contained in the proposal
// array and then returns the name of the winner
function winnerName() external view
    returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

///  NEEDED IMPROVEMENTS

// How can we req fewer tx's to assign the right to vote to all participants?
// further gas optimizations?
