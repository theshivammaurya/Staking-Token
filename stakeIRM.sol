// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract stakeIRM is Ownable,ReentrancyGuard,Pausable {
    
    IERC20 public irmToken;

    //  // 30 Days (30 * 24 * 60 * 60)
    // uint256 public _planDuration = 2592000;
       // 30 Days (30 * 24 * 60 * 60)
    uint256 public _planDuration = 60;

    // 180 Days (180 * 24 * 60 * 60)
    uint256 _planExpired = 15552000;

    uint8 public interestRate = 12;
    uint256 public planExpired;
    uint8 public totalStakers;

      struct StakeInfo {        
        uint256 startTS;
        uint256 endTS;        
        uint256 amount; 
        uint256 claimed;       
    }

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    constructor(address irmTokenAddress){
        require(irmTokenAddress != address(0),"Token address cannot be the 0 address");
        irmToken = IERC20(irmTokenAddress);
        planExpired = block.timestamp + _planExpired;
        totalStakers= 0;
    }

    function transferToken(address to, uint256 amount) external onlyOwner {
       require(irmToken.transfer(to, amount),"Token transfered failed");
    }


    function stakeToken(uint256 stakeAmount) external payable whenNotPaused{
       require(stakeAmount > 0,"Stake amount should be greater than 0");
       require(block.timestamp < planExpired, " Staking time Expire");
       require(addressStaked[msg.sender]== false,"You already Participated");
       require(irmToken.balanceOf(msg.sender)  >= stakeAmount,"Insufficient Amount");

       irmToken.transferFrom(msg.sender, address(this), stakeAmount);
          totalStakers++;
          addressStaked[msg.sender]=true;

          stakeInfos[msg.sender] = StakeInfo({                
                startTS: block.timestamp,
                endTS: block.timestamp + _planDuration,
                amount: stakeAmount,
                claimed: 0
            });  

        emit Staked(_msgSender(), stakeAmount);    
    }

    function claimedReward() external nonReentrant returns(bool){
        require(addressStaked[msg.sender]==true,"You are not participated");
        require(stakeInfos[msg.sender].endTS < block.timestamp,"Stake time is not over");
        require(stakeInfos[msg.sender].claimed == 0, "Already claimed");

         uint256 stakeAmount = stakeInfos[msg.sender].amount;
         uint256 totalTokens = stakeAmount + (stakeAmount * interestRate / 100);
         stakeInfos[msg.sender].claimed = totalTokens;
         irmToken.transfer(msg.sender, totalTokens);

         emit Claimed(msg.sender, totalTokens);

         return true;        
    }

    function getTokenExpiry() external view returns(uint256){
     require(addressStaked[msg.sender]== true,"you are not participated");
      return stakeInfos[_msgSender()].endTS;
    }

      function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}