pragma solidity ^0.5.1;
import "../contracts/SimpleContract.sol";
import "truffle/Assert.sol"; // Imports the Assert functions.
import "truffle/DeployedAddresses.sol"; // Imports the Deployed Addresses.

contract ThrowProxy {

    address public target;
    bytes data;
    constructor(address _target) public {
        target = _target;
    }

    //prime the data using the fallback function.
    function() external {
        data = msg.data;
    }
    function execute() public returns (bool) {
        (bool success, bytes memory returnData) = target.call(data);
        return success;
    }

} 



contract TestSimpleContract {
    address acc0;   //Variables used to emulate different accounts
    address acc1;   //Variables used to emulate different accounts
    address acc2;   //Variables used to emulate different accounts
    function beforeAll() public {
      SimpleContract myContract = new SimpleContract();
      acc0 = address(DeployedAddresses.SimpleContract());//.accounts[1]; //Initiate acc variables
      acc1 = address(0xC55aF5b97eD42d528CE2accFBB8CdFABd9836Dc5);//.accounts[1]; //Initiate acc variables
      acc2 = address(0xD6E7D54d4Ab848D4c2467E9D52E0489d03A4c2e5);
    }
    function testNotEqualAddresses_acc0_acc1() public {
        Assert.notEqual(address(acc1), address(acc0),'acc0 and acc1 should be different.');
    }
    function testEqualAddresses_acc0_DeployedAddresses() public {
        Assert.equal(
            address(DeployedAddresses.SimpleContract()), address(acc0),
            "acc0 should be equivalent to DeployedAddresses.SimpleContract(). \n If not then you probably didn\'t run ganache with mnemonic for deterministic addresses.\n ganache-cli -u 0 -m 'daughter shaft pepper better virus rather meadow way cotton above faint reopen'   ");
    }
    function testModifierTrueAcc0() public {
        ThrowProxy mythrowProxy = new ThrowProxy(address(acc0));
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)(); 
        Assert.isFalse(bool(r), "Should be true because is should not throw!");
    }
    function testModifierFalseAcc0() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc1);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)(); 
        Assert.isTrue(bool(r), "Should be true because is should not throw!");

    }

    function testModifierTrue() public {
        SimpleContract myContract = SimpleContract(DeployedAddresses.SimpleContract());
        ThrowProxy mythrowProxy = new ThrowProxy(address(myContract));
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)(); 
        Assert.isFalse(bool(r), "Should be true because is should not throw!");

    }
    function testModifierFalse() public {
        SimpleContract myContract = SimpleContract(DeployedAddresses.SimpleContract());
        // ThrowProxy mythrowProxy = new ThrowProxy(address(CB));

        ThrowProxy mythrowProxy = new ThrowProxy(address(0xC55aF5b97eD42d528CE2accFBB8CdFABd9836Dc5));
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)(); 
        Assert.isTrue(bool(r), "Should be true because is should not throw!");

    }

}