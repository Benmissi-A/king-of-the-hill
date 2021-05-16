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
    bool private _gameStart;
    //manque reentrancy attack
    //manque le dernier koh de recuperer indefiniment ses gains
    
    constructor(address owner_ , uint256 blockLimit_) payable {
        require(msg.value>0 , "put a seed befor initialisation");
        _owner = owner_;
        _seed = msg.value;
        _blockLimit = blockLimit_;
    }
    
    event Enthroned(address sender);
    event Payed(address indexed recipient, uint256 amount);
    event Refunded(address indexed recipient, uint256 rest);
    
    // surencherir sur la mise
    function offer() external payable {
        require(msg.value >= 2 * _seed , "KingOfTheHill: you need to put twice the value of the seed");
        
        if(_gameStart = false){
            _setStartingBlock();
            _gameStart = true;
        }
        
        if(msg.value> 2*_seed){
            uint256 rest = 2*_seed;
            payable(msg.sender).sendValue(msg.value - rest);
            emit Refunded(msg.sender, msg.value - rest);
        }
        _resolveTurn();
        
        _potOwner = msg.sender;
        emit Enthroned(msg.sender);
        _seed = address(this).balance;
    }
    
    // recuperer ses gains
    function _withdrawSeed() private {
         _seed = (address(this).balance * 10)/100;
         uint256 part = address(this).balance;
         payable(_potOwner).sendValue((part * 80)/100);
         payable(_owner).sendValue((part * 10)/100);
         emit Payed(_potOwner, (part * 80)/100);
    }
    
    // gere les tours de jeux
        function _setStartingBlock() private {
        _startingBlock = block.number;
    }
    
    function _resolveTurn() private {
        if(block.number - _startingBlock >= _blockLimit){
            if(_potOwner !=  0x0000000000000000000000000000000000000000 ){
                _withdrawSeed();
            }
            _nbTurn++;
            _setStartingBlock();
        }
    }
    
    
    
    // test & debug functions
      function viewPassedtBlocksNumber()public view returns (uint256) {
        return block.number - _startingBlock;
    }
    
    function getPotOwner() public view returns (address){
        return _potOwner;
    }
    
    function getSeed() public view returns (uint256){
        return _seed;
    }
    
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    function  viewBlockLimit()public view returns(uint256){
        return _blockLimit;
    }
    
    function viewStartingBlock()public view returns (uint256) {
        return _startingBlock;
    }
        function viewCurrentBlock()public view returns (uint256) {
        return block.number;
    }
    
      function viewTurn()public view returns (uint256) {
        return _nbTurn;
    }
    
    function withdrawAll() public {
        require(msg.sender == _owner , "Only Owner");
         _seed = 0;
         payable(_owner).sendValue(address(this).balance);
    }
    
}