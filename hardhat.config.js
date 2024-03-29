require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: process.env.TESTNET_ALCHEMY_RPC_URL,
      accounts: [process.env.TESTNET_PK],
    },
  }
};
