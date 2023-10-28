// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PromptSubmission {
    address public owner;
    uint256 public submissionEndTime;
    bool public submissionPeriodEnded;

    struct Prompt {
        address proposer;
        string content;
        bool accepted;
    }

    Prompt[] public prompts;

    event PromptSubmitted(address indexed proposer, string content);
    event SubmissionPeriodEnded();

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
        prompts.push(Prompt(msg.sender, _content, false));
        emit PromptSubmitted(msg.sender, _content);
    }

    function endSubmissionPeriod() external onlyOwner {
        require(!submissionPeriodEnded, "Submission period already ended");
        submissionEndTime = block.timestamp;
        submissionPeriodEnded = true;
        emit SubmissionPeriodEnded();
    }
}
