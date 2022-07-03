// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interfaces/IERC20.sol";

error RandomIpfsNft__TransferFailed();
error TheChinaShop__ListingInactive();
error TheChinaShop__CancelFailed();

contract TheChinaShop is Ownable {
    struct Listing {
        bool ongoing;
        bool canceled;
        bool sold;
        address seller;
        uint256 ETHamount;
        uint256 TokenAmount;
        address buyer;
    }

    mapping(uint256 => Listing) public s_listings;
    mapping(address => uint256) public s_listingAmountToAddress;
    mapping(string => uint256) public s_methPool;

    string private constant listingMethPool = "listedMeth";
    string private constant ownerRemittance = "ownerPool";
    address public methContractAdress;
    IERC20 private methContract;
    uint256 public listingCounter = 0;
    uint256 public salesCounter = 0;
    uint256 public totalMethTraded = 0;
    uint256 public brokenPlates = 0;

    //Events
    event MethListed(Listing);

    constructor(address _methContractAdress) {
        s_methPool["listedMeth"] = 0;
        s_methPool["ownerPool"] = 0;
        methContractAdress = _methContractAdress;
        methContract = IERC20(methContractAdress);
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

    function listMeth(uint256 ethAmount, uint256 tokenAmount) public payable {
        Listing memory listing;
        listing.ongoing = true;
        listing.canceled = false;
        listing.sold = false;
        listing.seller = msg.sender;
        listing.ETHamount = ethAmount;
        listing.TokenAmount = tokenAmount;
        brokenPlates = tokenAmount / 100;

        s_listings[listingCounter] = listing;
        listingCounter++;

        methContract.transfer(address(this), tokenAmount + brokenPlates);
    }

    function buyMeth(Listing memory listing) public payable {
        if (listing.ongoing = true) {
            methContract.transfer(listing.seller, listing.ETHamount);
            listing.ongoing = false;
            listing.canceled = false;
            listing.sold = true;
            salesCounter++;
            totalMethTraded += listing.TokenAmount;
        } else {
            revert TheChinaShop__ListingInactive();
        }
    }

    function cancelListing(Listing memory listing) public {
        require(msg.sender == listing.seller);
        if (listing.ongoing = true) {
            listing.ongoing = false;
            listing.canceled = true;
            listing.sold = false;
            methContract.transferFrom(address(this), msg.sender, listing.TokenAmount);
        }
        revert TheChinaShop__CancelFailed();
    }

    function getTotalSales() public view returns (uint256) {
        return salesCounter;
    }

    function getTotalMethTraded() public view returns (uint256) {
        return totalMethTraded;
    }

    function getTotalMethBalance() public view returns (uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function getBrokenPlates() public view returns (uint256) {
        return brokenPlates;
    }

    function withdraw(string memory pool) public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: s_methPool[pool]}("");
        if (!success) {
            revert RandomIpfsNft__TransferFailed();
        }
    }

    function getListings(uint256 _index) public view returns (Listing memory) {
        return s_listings[_index];
    }
}
