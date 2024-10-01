/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.22",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                    evmVersion: "berlin",
                },
            },
        ],
    },
    networks: {
        hardhat: { chainId: 1337 },
        // Add other networks as needed
    },
};
