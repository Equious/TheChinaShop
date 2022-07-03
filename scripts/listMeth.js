const { ethers } = require("hardhat")

async function listMeth(tokenAmount) {
    const marketplace = await ethers.getContract("TheChinaShop")
    //const
}

listMeth()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
