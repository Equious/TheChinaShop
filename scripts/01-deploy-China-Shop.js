const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const _methContractAddress = "0xED5464bd5c477b7F71739Ce1d741b43E932b97b0"
    const args = [_methContractAddress]

    const chinaShop = await deploy("TheChinaShop", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(chinaShop.address, args)
    }

    log("------------------------------------------------------------")

    module.exports.tags = ["all", "chinashop"]
}
