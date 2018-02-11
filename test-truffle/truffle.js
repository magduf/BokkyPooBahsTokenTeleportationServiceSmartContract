// module.exports = {
//   // See <http://truffleframework.com/docs/advanced/configuration>
//   // to customize your Truffle configuration!
// };


module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545, //7545, //8545,
      network_id: "*", // Match any network id
      gas: 25000000
      
    },
    test: {
      host: "localhost",
      port: 8545, //7545, //8545,
      network_id: "*", // Match any network id
      gas: 25000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};


