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

```json
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