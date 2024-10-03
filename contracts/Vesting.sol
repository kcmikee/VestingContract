// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VestingContract {
    struct Stakeholder {
        uint256 totalTokens;
        uint256 releaseTime; // Unix timestamp
        uint256 claimedTokens;
    }

    address public immutable organizationAdmin;
    IERC20 public immutable token;
    mapping(address => Stakeholder) public stakeholders;
    mapping(address => bool) public whitelisted;

    event StakeholderAdded(
        address indexed stakeholder,
        uint256 tokens,
        uint256 releaseTime
    );
    event TokensClaimed(address indexed stakeholder, uint256 amount);
    event AdminWithdrawal(uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == organizationAdmin, "Not admin");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    constructor(address _token) {
        organizationAdmin = msg.sender;
        token = IERC20(_token);
    }

    function addStakeholder(
        address _stakeholder,
        uint256 _tokens,
        uint256 _releaseTime
    ) external onlyAdmin {
        require(!whitelisted[_stakeholder], "Already a stakeholder");
        stakeholders[_stakeholder] = Stakeholder({
            totalTokens: _tokens,
            releaseTime: _releaseTime,
            claimedTokens: 0
        });
        whitelisted[_stakeholder] = true;
        emit StakeholderAdded(_stakeholder, _tokens, _releaseTime);
    }

    function claimTokens() external onlyWhitelisted {
        Stakeholder storage stakeholder = stakeholders[msg.sender];
        require(
            block.timestamp >= stakeholder.releaseTime,
            "Vesting period not reached"
        );
        uint256 claimable = stakeholder.totalTokens - stakeholder.claimedTokens;
        require(claimable > 0, "No tokens to claim");

        stakeholder.claimedTokens += claimable;
        token.transfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    function withdrawAdmin(uint256 amount) external onlyAdmin {
        token.transfer(msg.sender, amount);
        emit AdminWithdrawal(amount);
    }
}
