const MockUsdc = artifacts.require("MockUSDC");

module.exports = function (deployer) {
    deployer.deploy(MockUsdc);
};