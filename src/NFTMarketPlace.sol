// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract NFTMarketplace is ReentrancyGuard, Ownable {
    using ECDSA for bytes32;

    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 deadline;
        bool isActive;
        bytes signature;
    }

    IERC721 public nftContract;
    uint256 public listingFee;
    uint256 public orderCounter;

    address[] public acceptedNFTContracts;

    mapping(uint256 => Order) public tokenIdToOrder;

    // Mapping of order ID to trade state (0: Initial, 1: Buyer Confirmed, 2: Seller Confirmed)
    mapping(uint256 => uint256) public tradeStates;

    constructor(address[] memory _nftContracts, uint256 _listingFee) {
        for (uint256 i = 0; i < _nftContracts.length; i++) {
            acceptedNFTContracts.push(_nftContracts[i]);
        }
        listingFee = _listingFee;
    }

    event OrderCreated(address indexed seller, uint256 indexed tokenId, uint256 price, uint256 deadline);
    event OrderCancelled(uint256 indexed tokenId);
    event OrderExecuted(uint256 indexed orderId, address indexed buyer);
    event TradeConfirmed(uint256 indexed orderId, address indexed confirmer);

    modifier onlySeller(uint256 _tokenId) {
        require(msg.sender == tokenIdToOrder[_tokenId].seller, "Only seller can perform this action");
        _;
    }

    modifier onlyAcceptedNFTContract(address _nftContract) {
        bool isAccepted = false;
        for (uint256 i = 0; i < acceptedNFTContracts.length; i++) {
            if (acceptedNFTContracts[i] == _nftContract) {
                isAccepted = true;
                break;
            }
        }
        require(isAccepted, "NFT contract not accepted");
        _;
    }

    function setListingFee(uint256 _newFee) external onlyOwner {
        listingFee = _newFee;
    }

    function createOrder(uint256 _tokenId, uint256 _price, uint256 _deadline, bytes memory _signature) external payable nonReentrant {
        require(tradeStates[_tokenId] == 0, "Invalid trade state");
        require(!tokenIdToOrder[_tokenId].isActive, "NFT is already listed");
        require(msg.value == listingFee, "Incorrect listing fee");
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_price > 0, "Price must be greater than zero");

        require(msg.sender != address(0), "Invalid token address");

        uint32 codeSize;
        address nftContractAddress = msg.sender;
        assembly {
            codeSize := extcodesize(nftContractAddress)
        }
        require(codeSize > 0, "Token address has no code");

        
        nftContract = IERC721(msg.sender);

        // require(nftContract.isApprovedForAll(msg.sender, address(this)), "Contract is not approved to manage tokens");


        tokenIdToOrder[_tokenId] = Order({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            deadline: _deadline,
            isActive: true,
            signature: _signature
        });

        orderCounter += 1;

        emit OrderCreated(msg.sender, _tokenId, _price, _deadline);
    }

    function confirmTrade(uint256 _orderId) external nonReentrant {
        require(tradeStates[_orderId] == 1, "Invalid trade confirmation state");

        Order storage order = tokenIdToOrder[_orderId];
        require(msg.sender == order.seller || msg.sender == address(this), "Only seller or contract can confirm");

        /** Mark the trade as Seller Confirmed **/
        tradeStates[_orderId] = 2;

        emit TradeConfirmed(_orderId, msg.sender);
    }

    function executeOrder(uint256 _orderId) external payable nonReentrant {
        require(_orderId <= orderCounter, "Invalid order ID");
        Order storage order = tokenIdToOrder[_orderId];
        if (tradeStates[_orderId] == 2) {
            require(_validateSignature(msg.sender, keccak256(abi.encodePacked(order.tokenId, order.price, order.seller, order.deadline)), order.signature), "Invalid signature");
            nftContract = IERC721(msg.sender);
            /** Transfer the NFT to the buyer **/
            nftContract.safeTransferFrom(order.seller, msg.sender, order.tokenId);

            /** Transfer the payment to the seller **/
            payable(order.seller).transfer(order.price);

            order.isActive = false;
        }
    }

    function getOrder(uint256 tokenId) external view returns (address seller, uint256 price, uint256 deadline, bool isActive, bytes memory signature) {
        Order storage order = tokenIdToOrder[tokenId];
        return (order.seller, order.price, order.deadline, order.isActive, order.signature);
    }

    function _validateSignature(address _signer, bytes32 hash, bytes memory signature) internal pure returns (bool) {
        bytes32 signedHash = hash.toEthSignedMessageHash();
        return signedHash.recover(signature) == _signer;
    }

    function addAcceptedNFTContract(address _nftContract) external onlyOwner {
        acceptedNFTContracts.push(_nftContract);
    }
}
