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
    SimpleContract myContract;
    // beforeAll is run before all of the other functions. We will use this to deploy the
    // contract and to set variable addresses.
    function beforeAll() public {
    myContract = new SimpleContract();
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
        Assert.isFalse(bool(r), "Owner unable to change value by owner");
    }

    //testModifierFalseAcc1
    // We will set the proxy to acc1 which should throw an error.
    // acc1 is not the owner of the contract.
    function testModifierFalseAcc1() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc1);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(6));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isTrue(bool(r), "Error NOT thrown when non-owner tried to change the value!");

    }
    // test_changeValueByOwner
    // This function will test that the value is actually changed when the changeValueByOwner
    // is called.
    function test_changeValueByOwner() public {
        myContract.changeValueByOwner(int(7));
        Assert.equal(myContract.getValue(),int(7),"Value was not changed by owner.");
    }

    // test_changeValueByOwner_proxy
    // Test to ensure that the changeValueByOwner doesn't throw an error when a proxy is used with acc0 (the deploy account).
    function test_changeValueByOwner_proxy() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc0);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(8));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isFalse(bool(r), "Error thrown when attempting to change the value by the owner.");

    }

    // test_changeValueByNonowner_proxy
    // Test that the changeValueByOwner returns a 'throw' when trying to change the value using the non-owner account (acc1.)
    function test_changeValueByNonowner_proxy() public {
        ThrowProxy mythrowProxy = new ThrowProxy(acc1);
        SimpleContract(address(mythrowProxy)).changeValueByOwner(int(8));
        bool r = mythrowProxy.execute.gas(200000)();
        Assert.isTrue(bool(r), "!!Error NOT thrown when attempting to change the value by a non-owner!!");
    }

    function test_changeOwnerByOwner() public {
        //SimpleContract myContract = new SimpleContract(); // Create contract
        myContract.changeOwner(address(acc1)); // Change the owner of the contract
        Assert.equal(address(acc1),address(myContract.getOwner()),"Owner was not changed by owner");

        //ThrowProxy mythrowProxy = new ThrowProxy(acc0); // Set the proxy to the original address. Should fail.
        //SimpleContract(address(mythrowProxy)).changeOwner(address(acc1));
        //bool r = mythrowProxy.execute.gas(200000)();
        //Assert.isFalse(bool(r), "Non-owner was able to change the value!");

    }
    function test_changeOwnerByOldOwner_proxy() public {
        SimpleContract newContract = new SimpleContract();
        newContract.changeOwner(address(acc1));
        Assert.equal(address(acc1),address(newContract.getOwner()),"Owner was not changed to acc1");

        ThrowProxy myThrowProxy_ACC1 = new ThrowProxy(acc1); // Create a proxy for acc1
        //ThrowProxy myThrowProxy_ACC0 = new ThrowProxy(acc0); // Create a proxy for acc0

        SimpleContract(address(myThrowProxy_ACC1)).changeOwner(address(acc2)); // Change the account from acc1 to acc2
        bool r = myThrowProxy_ACC1.execute.gas(200000)();
        Assert.isFalse(bool(r), "!!!Owner not able to change contract!");

        //SimpleContract(address(mythrowProxy2)).changeOwner(address(acc1)); // Change the account from acc0 to acc1


        //Assert.equal(address(acc1),address(newContract.getOwner()),"Owner was not changed to acc1");
        //Assert.equal(address(SimpleContract(address(mythrowProxy)).getOwner),address(acc1),'Proxy not changing value.');

    }


}