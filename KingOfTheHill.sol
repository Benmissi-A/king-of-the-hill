// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/// @title A king Of The Hill Game
/// @author Benmissi-A

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract KingOfTheHill{
    using Address for address payable;
    
    address private _owner;
    address private _potOwner;
    mapping(address => bool) private _potOwnerStatus; 
    uint256 private _seed;
    uint256 private _blockLimit;
    uint256 private _startingBlock;
    
    constructor(address owner_ , uint256 blockLimit_) payable {
        require(msg.value>0 , "put a seed before initialisation");
        _owner = owner_;
        _seed = msg.value;
        _blockLimit = blockLimit_;
    }
    
    /// @notice notify the address og the _potOwner
    ///@param sender is the player
    event Enthroned(address indexed sender);
    
    /// @notice notify transaction of withdraw for winner and owner

    event Payed(address indexed winner, uint256 amount , address owner , uint256 fees);
    /// @notice notify refund transaction 
  
    event Refunded(address indexed player, uint256 rest);
    
    /// @notice the reentrancy guard modifier of the game to be ensure that the winner is rewerded only one time
    modifier notPayed{
        require(_potOwnerStatus[_potOwner] != true , "notPayed: you ave already been payed");
        _potOwnerStatus[_potOwner]=true;
        _;
        _potOwnerStatus[_potOwner]=false;
        
    }
    
    /// @notice The main action in the game 
    /// @dev the function nothing there are only side effects by calling private functions 
    function offer() external payable {
        require(msg.value >= 2 * _seed , "KingOfTheHill: you need to put twice the value of the seed");
        /// @notice if the player put more than he need , he wil be refunded 
        if(msg.value> 2*_seed){
            uint256 rest = 2*_seed;
            payable(msg.sender).sendValue(msg.value - rest);
            emit Refunded(msg.sender, msg.value - rest);
        }
        _resolveTurn();
        _potOwner = msg.sender;
        emit Enthroned(msg.sender);
        _seed = address(this).balance;
        _setStartingBlock();
    }
    
    /// @notice the function rewrd the winner , 80% to the winner , 10% to the owner and 10% stay in the seed 
    function _withdrawSeed() private notPayed {
        _seed = (address(this).balance * 10)/100;
        uint256 part = address(this).balance;
        payable(_potOwner).sendValue((part * 80)/100);
        payable(_owner).sendValue((part * 10)/100);
        emit Payed(_potOwner, (part * 80)/100, _owner ,(part * 10)/100);
    }
    
    /// @notice set a new startingBlock for the game 
        function _setStartingBlock() private {
        _startingBlock = block.number;
    }
    
    /// @notice resolve the turn when the number of elapsed blocks is blocks match the winnig condition 
    function _resolveTurn() private {
        if(block.number - _startingBlock >= _blockLimit){
            if( _potOwner !=  address(0) ){
                _withdrawSeed();
            }
            _setStartingBlock();
        }
    }
    
    
    
    /// @notice i did not remove these functions but they are for testing and debug
        
        /// @notice return the nuber of elapsed blocks since the last offer 
        /// @dev return an uint256 
    function viewPassedtBlocksNumber()public view returns (uint256) {
        return block.number - _startingBlock;
    }
    /// @notice return the current potOwner 
    /// @dev return an address 
    function getPotOwner() public view returns (address){
        return _potOwner;
    }
    
    /// @notice get the seed 
    /// @dev return an uint256 
    function getSeed() public view returns (uint256){
        return _seed;
    }
    
    /// @notice get the balance of the smart contract the same value as the seed
    /// @dev return an uint256 
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    /// @notice to check the number of blocks to win
    /// @dev return an uint256 
    function  viewBlockLimit()public view returns(uint256){
        return _blockLimit;
    }
    
    /// @notice to check the initial block of the turn
    /// @dev return an uint256 
    function viewStartingBlock()public view returns (uint256) {
        return _startingBlock;
    }
    /// @notice to check the current block of the turn
    /// @dev return an uint256 
        function viewCurrentBlock()public view returns (uint256) {
        return block.number;
    }
    
    /// @notice a security function to keep the money if i made a mistake , sorry only for the owner
    function withdrawAll() public {
        require(msg.sender == _owner , "Only Owner");
         _seed = 0;
         payable(_owner).sendValue(address(this).balance);
    }
    
}