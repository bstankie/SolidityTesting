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
    SimpleContract newContract = new SimpleContract();
    address origOwnerAddress = address(newContract.getOwner());   //Variables used to emulate different accounts
    address newContractAddress = address(newContract.address())
    address acc0 = address(0x87379501c993c876A57cBE91438Ef59CcdDc3cB0);   //Variables used to emulate different accounts
    address acc1 = address(0x4B710574671B3727FD2c5180e4626eC507d67E1D);   //Variables used to emulate different accounts
    address acc2 = address(0x3DB3017E532f7b87b7c6611BE853B340CbbcFd1D);   //Variables used to emulate different accounts
    address acc3 = address(0x6Cf48E0f71Fd1e071B66397c8ca755a61C761c54);   //Variables used to emulate different accounts
    // beforeAll is run before all of the other functions. We will use this to deploy the
    // contract and to set variable addresses.
    function testEqualAddresses_acc0_DeployedAddresses() public {
        Assert.equal(
            address(DeployedAddresses.SimpleContract()), address(acc0),
            "acc0 should be equivalent to DeployedAddresses.SimpleContract()."
        );
    }

    function test_Owner_acc0() public {
        // Check to be sure that the current owner is still acc0.
        Assert.equal(address(acc0),address(newContract.getOwner()),"Owner is not acc0");
    }
    function test_changeOwnerByOldOwner_proxy() public {

        ThrowProxy myThrowProxy_ACC0 = new ThrowProxy(acc0);                    // Create a proxy for acc0
        SimpleContract(address(myThrowProxy_ACC0)).changeOwner(address(acc2));  // Change the account from acc1 to acc2
        bool r = myThrowProxy_ACC0.execute.gas(200000)();                       // Execute the change owner with ACC0
        Assert.isFalse(bool(r), "!!!Owner not able to change contract!");
        Assert.equal(address(acc2),address(newContract.getOwner()),"Owner was not changed to acc2 using proxy!");

        newContract.changeOwner(address(acc1));
        Assert.equal(address(acc1),address(newContract.getOwner()),"Owner was not changed to acc1 by newContract owner");
        
        //
        //SimpleContract(address(myThrowProxy_ACC0)).changeOwner(address(acc2)); // Change the account from acc1 to acc2
        //bool r = myThrowProxy_ACC0.execute.gas(200000)();
        //Assert.isFalse(bool(r), "!!!Owner not able to change contract!");

        //SimpleContract(address(mythrowProxy2)).changeOwner(address(acc1)); // Change the account from acc0 to acc1


        //Assert.equal(address(acc1),address(newContract.getOwner()),"Owner was not changed to acc1");
        //Assert.equal(address(SimpleContract(address(mythrowProxy)).getOwner),address(acc1),'Proxy not changing value.');

    }


}
