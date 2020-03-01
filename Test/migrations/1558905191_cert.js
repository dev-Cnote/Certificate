const Cert = artifacts.require("Cert");

module.exports = function(deployer) {
  deployer.deploy(Cert);
};
