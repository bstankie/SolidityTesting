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
    address origOwnerAddress = address(newContract.getOwner());   // Address of the original owner of the contract
    address newContractAddress = address(newContract);  // I thought that this was the address of the owner.
    // ----- Generate Known addresses using mnemonic------
    // using ganache-cli we generate these addresses using a mnemonic:
    // ganache-cli -m "easily trophy acoustic same lunch vibrant reflect clerk bacon donor retire frown"
    // ----- Generate Known addresses using mnemonic------
    address acc0 = address(0x87379501c993c876A57cBE91438Ef59CcdDc3cB0);   //Variables used to emulate different accounts
    address acc1 = address(0x4B710574671B3727FD2c5180e4626eC507d67E1D);   //Variables used to emulate different accounts
    address acc2 = address(0x3DB3017E532f7b87b7c6611BE853B340CbbcFd1D);   //Variables used to emulate different accounts
    address acc3 = address(0x6Cf48E0f71Fd1e071B66397c8ca755a61C761c54);   //Variables used to emulate different accounts
    // beforeAll is run before all of the other functions. We will use this to deploy the
    // contract and to set variable addresses.

    // Test if the DeployedAddresses is equivalent to the original owner.
    // (Fails) Interpretation: Owner is not the same as DeployedAddresses.<Contract>.
    function test_DeployedAddresses_eq_getOwener() public {
        Assert.equal(
            address(newContract.getOwner()),address(newContract),
            'newContract.getOwner() not equal to DeployedAddresses.SimpleContract()'
        );
    }
    // Test to see if the originalwner (getOwner()) is equivalent to address[0].
    function testEqualAddresses_acc0_DeployedAddresses() public {
        Assert.equal(
            address(newContract.getOwner()), address(acc0),
            "address[0] is NOT  equivalent to newContract.getOwner(). \n\t----> Interpretation:address[0] is not used as the default address."
        );
    }
    function test_changeOwnerByProxy_getOwner() public {
        ThrowProxy myThrowProxy_ACC0 = new ThrowProxy(address(newContract.getOwner()));                    // Create a proxy for acc0
        SimpleContract(address(myThrowProxy_ACC0)).changeOwner(address(acc1));  // Change the account from acc1 to acc2
        bool r = myThrowProxy_ACC0.execute.gas(200000)();                       // Execute the change owner with ACC0
        Assert.isFalse(bool(r), "!!!newContract.getOwner() owner not able to change contract through proxy!");
    }
    // Test to see if owner was changed through the proxy.
    // (Fails) Interpretation: ThrowProxy does not change the owner. I believe that the new ThrowProxy(address(newContract.getOwner()))
    // creates a new contract.
    function test_accountChangedBy_Proxy() public {
        Assert.equal(address(acc1),address(newContract.getOwner()),'Proxy Fail: acc1 and newContract.getOwner() not the same');
    }
    function test_accountChangedBy_newContract() public {
        newContract.changeOwner(address(acc1));
        Assert.equal(address(acc1),address(newContract.getOwner()),'newContract Fail:acc1 and newContract.getOwner() not the same');
    }
}
