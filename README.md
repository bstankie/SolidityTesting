# SolidityTesting

Simple Solidity Testing using Truffle and Genache

## Setup

Initialize the folder.

```bash
> truffle init
```

Start genache
```bash
> ganache-cli -u 0
```

Look for address and port that system is listening on: 

```Listening on 127.0.0.1:8545```

Here it is on port:**8545**

At localhost: **127.0.0.1**

Modify truffle-config.js in your repo for the address and the port.

```yaml
networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
     },
}
```

We need to setup the migration file to generate the simpleContract.sol. Create a file called ```./migrations/2_initial_migrations.js```. You can copy the ```./migrations/1_initial_migrations.js``` file and modify. You need to change the *const* and put the path to the ```.sol``` file along with specifying it in the ```deployer.deploy(...)``` command.

## Testing code.

We are trying to build the unit tests so that we can test changing the owner and ensure that the old owner cannot still make changes to the contract.

We will use the mnemonic so that we know the addresses. Not sure if this is necessary but it is one less thing to worry about during the debugging.

```bash
$ ganache-cli -m "easily trophy acoustic same lunch vibrant reflect clerk bacon donor retire frown"

# First 5 addresses.
# (0) 0x87379501c993c876A57cBE91438Ef59CcdDc3cB0 (100 ETH)
# (1) 0x4B710574671B3727FD2c5180e4626eC507d67E1D (100 ETH)
# (2) 0x3DB3017E532f7b87b7c6611BE853B340CbbcFd1D (100 ETH)
# (3) 0x6Cf48E0f71Fd1e071B66397c8ca755a61C761c54 (100 ETH)
# (4) 0xBbF6971b8cD62822C39eF834e8DCcd5F37315b97 (100 ETH)
# (5) 0x736CcD6c9061Dda3d6753eF73cE3F82566a1e7a3 (100 ETH)
```

Run the test from the command line.

``` bash
$ truffle test ./test/Test_SuperSimple.sol
```


## Erata

Create the migration file:

```python
const SimpleContract = artifacts.require("./SimpleContract.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleContract);
};

```

Start the truffle development environment 
```bash
> truffle develop
```

Migrate the contracts:

```bash
truffle(develop)> migrate
```

Load your instance so you can interact with it.
```bash
truffle(develop)> SimpleContract.deployed().then(function(instance) {app = instance;})
```

The contract is deployed using the first (or zeroth) account. Here we can change the value and specify using the first address.
This should execute.

```bash
app.changeValueByOwner(6,{from: accounts[0]})
```
The contract is deployed using the first (or zeroth) account. Here we specify that the sender is the second account which is not the owner (or deployer). Because of our *modifier* that we put on *changeValueByOwner* this should now fail.

```bash
app.changeValueByOwner(6,{from: accounts[1]})
```


## References

[Using Truffle! Blockgeeks Live Coding Webinar](https://youtu.be/nRySHw123x8)

[Deployed Addresses](http://www.talkcrypto.org/blog/2019/01/11/where-is-deployedaddresses-sol-when-testing-in-truffle/)