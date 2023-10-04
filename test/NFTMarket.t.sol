// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {NFTMarketplace} from "../src/NFTMarketPlace.sol";


import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface INFTProto {
    function mintNFT(address recipient, string memory _tokenURI) external;

    function setApprovalForAll(address operator, bool _approved) external;
}

contract NFTMarketplaceTest is Test {
    using ECDSA for bytes32;

    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 deadline;
        bool isActive;
        bytes signature;
    }

    NFTMarketplace public nftMarketPlaceContract;

    uint256 internal _userPrivateKey;
    uint256 internal _signerPrivateKey;
    uint256 _price = 2 ether;
    address[] _tokenAddresses =[0x168Ca561E63C868b0F6cC10a711d0b4455864f17];
    uint256 _tokenId;
    uint256 _tradeState;

    function setUp() public {
        console2.logAddress(msg.sender);
        console2.logString("<<<<<<msg sender>>>>>>");

        nftMarketPlaceContract = new NFTMarketplace(_tokenAddresses, _price);

        _userPrivateKey = 0xa11ce;
        _signerPrivateKey = 0xabc123;

        _tokenId = 1;

        _tradeState = nftMarketPlaceContract.tradeStates(_tokenId);
    }

    function testCreateOrder() public {
        console2.logUint(_tradeState);
        console2.logString("<<<<<<trade state>>>>>>");

        (address seller, uint256 price, uint256 deadline, bool isActive, bytes memory signature) = nftMarketPlaceContract.getOrder(_tokenId);

        console2.logBool(isActive);
        console2.logString("<<<<<<isActive>>>>>>");

        console2.logBytes(signature);
        console2.logString("<<<<<<signature>>>>>>");

        console2.logAddress(seller);
        console2.logString("<<<<<<seller>>>>>>");

        deadline = block.timestamp + 1000;

        console2.logUint(deadline);
        console2.logString("<<<<<<deadline>>>>>>");

        price = _price;

        console2.logUint(price);
        console2.logString("<<<<<<price>>>>>>");

        nftMarketPlaceContract.addAcceptedNFTContract(msg.sender);

        console2.logAddress(nftMarketPlaceContract.acceptedNFTContracts(1));
        console2.logString("<<<<<<acceptedNFTContracts>>>>>>");
        console2.logAddress(msg.sender);

        vm.deal(msg.sender, price);

        //create a new nft contract
        INFTProto nftContract = INFTProto(nftMarketPlaceContract.acceptedNFTContracts(1));

    //    nftContract.setApprovalForAll(address(nftMarketPlaceContract), true);


        nftMarketPlaceContract.createOrder{value: price}(
            _tokenId,
            price,
            deadline,
            signature
        );
    }

    function testInvalidTradeState() public {
        console2.logUint(_tradeState);
        console2.logString("<<<<<<trade state>>>>>>");

        (address seller, uint256 price, uint256 deadline, bool isActive, bytes memory signature) = nftMarketPlaceContract.getOrder(_tokenId);

        deadline = block.timestamp + 1000;

        price = _price;


        nftMarketPlaceContract.createOrder{value: price}(
            _tokenId,
            price,
            deadline,
            signature
        );
        
        vm.expectRevert(bytes("Invalid trade state"));
        nftMarketPlaceContract.createOrder{value: price}(
            _tokenId,
            price,
            deadline,
            signature
        );
    }



    // function testExecuteOrder() public {
    //     console2.logUint(_tradeState);
    //     console2.logString("<<<<<<trade state>>>>>>");

    //     (address seller, uint256 price, uint256 deadline, bool isActive, bytes memory signature) = nftMarketPlaceContract.getOrder(_tokenId);

    //     console2.logUint(price);
    //     console2.logString("<<<<<<price>>>>>>");

    //     console2.logBool(isActive);
    //     console2.logString("<<<<<<isActive>>>>>>");

    //     console2.logBytes(signature);
    //     console2.logString("<<<<<<signature>>>>>>");

    //     console2.logAddress(seller);
    //     console2.logString("<<<<<<seller>>>>>>");

    //     address user = vm.addr(_userPrivateKey);
    //     address signer = vm.addr(_signerPrivateKey);
    //     deadline = block.timestamp + 1000;

    //     console2.logUint(deadline);
    //     console2.logString("<<<<<<deadline>>>>>>");

    //     vm.startPrank(signer);
    //     // bytes32 digest = keccak256(abi.encodePacked(_tokenId, _price, user, deadline)).toEthSignedMessageHash();
    //     // (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
    //     // bytes memory signature = abi.encodePacked(r, s, v); 
    //     // vm.stopPrank();

    //     // vm.startPrank(user);

    //     // vm.deal(user, _price);

    //     // nftMarketPlaceContract.createOrder{value: _price}(
    //     //     _tokenId,
    //     //     _price,
    //     //     deadline,
    //     //     signature
    //     // );
    //     // vm.stopPrank();
    // }
}


