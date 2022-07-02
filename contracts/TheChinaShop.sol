// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNft__TransferFailed();

contract TheChinaShop is Ownable {
    mapping(address => uint256) public s_listingAmountToAddress;
    mapping(string => uint256) public s_methPool;

    string private constant listingMethPool = "listedMeth";
    string private constant ownerRemittance = "ownerPool";

    //Events
    event MethListed(uint256 ethListPrice);

    constructor() {
        s_methPool["listedMeth"] = 0;
        s_methPool["ownerPool"] = 0;
    }

    // 1. function to create a listing
    //    - get approval to spend from wallet for amount to sell
    //    - allow seller to set the volume of amount approved
    //    - allow seller to set the price for the batch - display cost/Meth in USD
    // 2. function to purchase a listing
    //    - payable function with value required to be equal to the price of the listing
    //    - function need to transfer Meth from the contract to the payer and deduct the msg.value
    //    - will need to remove listing from viewable array
    //    - Small percentage cut goes to ME, CUNTS
    // 3. function to view total meth on contract
    //

    function listMeth(uint256 methAmount, uint256 ethListPrice) public {
        s_listingAmountToAddress[msg.sender] = methAmount;
        emit MethListed(ethListPrice);
    }

    function getTotalMethBalance() public view returns (uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function withdraw(string memory pool) public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: s_methPool[pool]}("");
        if (!success) {
            revert RandomIpfsNft__TransferFailed();
        }
    }
}
