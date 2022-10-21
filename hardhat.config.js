require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require('hardhat-dependency-compiler');

module.exports = {
    networks: {
      hardhat: {
        allowUnlimitedContractSize: true,
        gas: 3000000,
        gasPrice: 8000000000,
      }  
    },
    solidity: {
      compilers: [
        { version: "0.8.7" },
        { version: "0.7.6" },
        { version: "0.6.6" }
      ]
    },
    dependencyCompiler: {
      paths: [
        '@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol',
        '@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol',
      ],
    }
}
