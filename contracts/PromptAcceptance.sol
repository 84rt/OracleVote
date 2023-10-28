// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PromptAcceptance {
    address public owner;
    uint256 public submissionEndTime;
    bool public submissionPeriodEnded;

    struct Prompt {
        address proposer;
        string content;
        uint256 totalStake; // Total stake backing this prompt
        bool accepted;
    }

    mapping(uint256 => Prompt) public prompts; // Mapping from prompt index to Prompt struct
    uint256 public promptCount;

    event PromptSubmitted(address indexed proposer, string content);
    event SubmissionPeriodEnded();
    event PromptAccepted(uint256 indexed promptIndex);

    constructor() {
        owner = msg.sender;
        submissionPeriodEnded = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier duringSubmissionPeriod() {
        require(!submissionPeriodEnded, "Prompt submission period has ended");
        _;
    }

    function submitPrompt(string memory _content) external duringSubmissionPeriod {
        prompts[promptCount] = Prompt(msg.sender, _content, 0, false);
        emit PromptSubmitted(msg.sender, _content);
        promptCount++;
    }

    function endSubmissionPeriod() external onlyOwner {
        require(!submissionPeriodEnded, "Submission period already ended");
        submissionEndTime = block.timestamp;
        submissionPeriodEnded = true;
        emit SubmissionPeriodEnded();
    }

    function voteForPrompt(uint256 _promptIndex) external payable duringSubmissionPeriod {
        require(_promptIndex < promptCount, "Invalid prompt index");
        prompts[_promptIndex].totalStake += msg.value;
    }

    function acceptPrompt(uint256 _promptIndex) external onlyOwner {
        require(_promptIndex < promptCount, "Invalid prompt index");
        require(!prompts[_promptIndex].accepted, "Prompt already accepted");

        // Check if the total stake meets a threshold (e.g., 100 ETH)
        if (prompts[_promptIndex].totalStake >= 100 ether) {
            prompts[_promptIndex].accepted = true;
            emit PromptAccepted(_promptIndex);
            // Optionally: Transfer the total stake to the proposer
            payable(prompts[_promptIndex].proposer).transfer(prompts[_promptIndex].totalStake);
        }
    }
}
