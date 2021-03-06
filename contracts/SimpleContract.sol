pragma solidity ^0.5.16;

contract SimpleContract {
    int currVal;
    address owner;
    constructor() public {
        owner = msg.sender; // Set the owner to the person that created the contract.
        currVal=0;
    }
    // onlyOwner is a modifier that will be used to prevent non-owners from doing things.
    modifier onlyOwner{
        require(
          address(msg.sender) == address(owner),
          'Only the owner can do this function.');
        _;
    }
    function changeValueByOwner(int _inputVal) public onlyOwner {
        currVal = _inputVal;
    }
    function getValue() public view returns(int){
        return currVal;
    }
    function getOwner() public view returns(address){
        return owner;
    }

    function changeOwner(address _receiver) public onlyOwner {
        owner = _receiver;
    }
}