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
      gas: 4500000
      //, from: "0x3cce38471635b96341c17b07d59f8abdfbde1118" //geth dev mode coinbase

      
    },
    test: {
      host: "localhost",
      port: 8545, //7545, //8545,
      network_id: "*", // Match any network id
      gas: 4500000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};


