// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract KingOfTheHill{
    using Address for address payable;
    
    address private _owner;
    address private _potOwner;
    uint256 private _seed;
    uint256 private _nbTurn;
    uint256 private _blockLimit;
    uint256 private _startingBlock;
    
    constructor(address owner_ , uint256 blockLimit_ ) payable {
        _owner = owner_;
        _seed = msg.value;
        _blockLimit= blockLimit_;
   
        
    }
    
    event Enthroned(address sender);
    event Payed(address recipient, uint256 amount);
    
    // surencherir sur la mise
    function offer() external payable {
        if(_nbTurn == 0){
            setStartingBlock();
        }
        resolveTurn();
        require(msg.value >= 2 * _seed , "KingOfTheHill: you need to put twice the value of the seed");
        
        if(msg.value> 2*_seed){
            uint256 rest = 2*_seed;
            payable(msg.sender).sendValue(msg.value - rest);
        }
        
        _seed = address(this).balance;
        _potOwner = msg.sender;
        
        emit Enthroned(msg.sender);
    }
    
    // recuperer ses gains
    function withdrawSeed() public {
         _seed = (address(this).balance * 10)/100;
         uint256 part = address(this).balance;
         payable(_potOwner).sendValue((part * 80)/100);
         payable(_owner).sendValue((part * 10)/100);
         
         emit Payed(_potOwner, address(this).balance);
    }
    
    function withdrawAll() public {
         _seed = 0;
         payable(_owner).sendValue(address(this).balance);
    }
    
    // gere les tours de jeux
        function setStartingBlock() public {
        _startingBlock = block.number;
    }
    
      function CountBlocks()public view returns (uint256) {
        return block.number - _startingBlock;
    }
    
    function resolveTurn() public {
        if(block.number - _startingBlock == _blockLimit){
            withdrawSeed();
            _nbTurn++;
            setStartingBlock();
        }
    }
    
    
    
    // test & debug functions
    
    function getPotOwner() public view returns (address){
        return _potOwner;
    }
    
    function getSeed() public view returns (uint256){
        return _seed;
    }
    
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    function viewStartingBlock()public view returns (uint256) {
        return _startingBlock;
    }
    
      function view()public view returns (uint256) {
        return _startingBlock;
    }
    
}