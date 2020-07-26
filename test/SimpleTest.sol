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

    // beforeAll is run before all of the other functions. We will use this to deploy the
    // contract and to set variable addresses.
    function beforeAll() public {
      SimpleContract myContract = new SimpleContract();
      acc0 = address(DeployedAddresses.SimpleContract());//.accounts[1]; //Initiate acc variables
      acc1 = address(0xC55aF5b97eD42d528CE2accFBB8CdFABd9836Dc5);//.accounts[1]; //Initiate acc variables
      acc2 = address(0xD6E7D54d4Ab848D4c2467E9D52E0489d03A4c2e5);
    }

    //testNotEqualAddresses_acc0_acc1
    // Tests to be sure that acc0 and acc1 are not equal. acc0 will be used to ensure that the modifier of 'owner'
    // is working properly.
    function testNotEqualAddresses_acc0_acc1() public {
        Assert.notEqual(address(acc1), address(acc0),'acc0 and acc1 should be different.');
    }

    //testEqualAddresses_acc0_DeployedAddresses
    // We want to make sure that acc0 is equivalent to the deployed address. This will confirm
    // that the owner can do what needs to be done.
    function testEqualAddresses_acc0_DeployedAddresses() public {
        Assert.equal(
            address(DeployedAddresses.SimpleContract()), address(acc0),
            "acc0 should be equivalent to DeployedAddresses.SimpleContract()."
        );
    }
    // testModifierTrueAcc0
    // Test that the owner can do what they need to do with the function changeValueByOwner (through the modifier).
    // @e will use acc0 as the proxy address to test.
    function testModifierTrueAcc0() public {
        ThrowProxy mythrowProxy = new ThrowProxy(address(acc0));
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)(); 
        Assert.isFalse(bool(r), "Should be false because is should NOT throw an error!");
    }

    //testModifierFalseAcc1
    // We will set the proxy to acc1 which should throw an error.
    // acc1 is not the owner of the contract.
    function testModifierFalseAcc1() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc1);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isTrue(bool(r), "Should be true because it should throw an error: acc1 != owner!");

    }
    // test_changeValueByOwner
    // This function will test that the value is actually changed when the changeValueByOwner
    // is called.
    function test_changeValueByOwner() public {
        SimpleContract myContract = new SimpleContract();
        myContract.changeValueByOwner(int(7));
        Assert.equal(myContract.getValue(),int(7),"Value was not changed to 7.");
    }

    // test_changeValueByOwner_proxy
    // Test to ensure that the changeValueByOwner doesn't throw an error when a proxy is used with acc0 (the deploy account).
    function test_changeValueByOwner_proxy() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc0);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(8));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isFalse(bool(r), "Should be true because it should throw an error: acc1 != owner!");

    }

    // test_changeValueByNonowner_proxy
    // Test that the changeValueByOwner returns a 'throw' when trying to change the value using the non-owner account (acc1.)
    function test_changeValueByNonowner_proxy() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc1);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(8));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isTrue(bool(r), "Should be true because it should throw an error: acc1 != owner!");

    }

}