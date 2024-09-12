// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MooveUtilsV1_1.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

contract MooveNFT is VRFConsumerBaseV2Plus, ERC721URIStorage, MooveUtilsV1_1 {

    struct RequestStatus {
        bool fulfilled; 
        bool exists;
        uint256[] randomWords;
        bool winner;
    }
    
    uint256 public tokenCounter;
    uint256 public maxSupply;
    uint256 public creationFee;
    uint256 internal fee;

    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint8) public requestIdToVechileType;

    event NFTRequest(uint256 requestId, uint256 numWords);
    event NFTCreated(uint256 indexed tokenId, uint256 randomNumber);
    event WinnerRequest(uint256 requestId, uint256 numWords);
    event WinnerExtracted(uint256 requestId, uint256 tokenId, address owner);

    mapping(uint256 => RequestStatus) public requests;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256 public lastWinnerTokenId;
    bool public winnerExtracted;

    // VRF variables
    uint256 private _subscriptionId;
    bytes32 private _keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private _callbackGasLimit = 2500000;
    uint16 private _requestConfirmations = 3;
    uint32 private _numWords = 1;

    constructor(uint256 _subId, uint256 _maxSupply, uint256 _creationFee)
        VRFConsumerBaseV2Plus(0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B)
        ERC721("MooveNFT", "MOOVE")
    {
        _subscriptionId = _subId;
        maxSupply = _maxSupply;
        creationFee = _creationFee;
    }

    function requestNFT(uint8 vehicleType) external payable {
        require(tokenCounter < maxSupply, "Max supply reached");
        require(msg.value >= creationFee, "Insufficient fee");
        uint256 requestId = requestRandomWords(false);
        requestIdToSender[requestId] = msg.sender;
        requestIdToVechileType[requestId] = vehicleType;
        emit NFTRequest(requestId, _numWords);
    }

    function requestWinner() public onlyOwner {
        require(tokenCounter > 1, "Not enough tokens created");
        winnerExtracted = false;
        uint256 requestId = requestRandomWords(true);
        requestIdToSender[requestId] = msg.sender;
        emit WinnerRequest(requestId, _numWords);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setCreationFee(uint256 _creationFee) public onlyOwner {
        creationFee = _creationFee;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    // VRF 
    function requestRandomWords(bool extractWinner) internal returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: _keyHash,
                subId: _subscriptionId,
                requestConfirmations: _requestConfirmations,
                callbackGasLimit: _callbackGasLimit,
                numWords: _numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            winner: extractWinner
        });

        requestIds.push(requestId);
        lastRequestId = requestId;
        
        return requestId;
    }
    
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        require(requests[requestId].exists, "request not found");
        requests[requestId].fulfilled = true;
        requests[requestId].randomWords = randomWords;

        if(requests[requestId].winner){

            uint256 tokenId = extractWinner(randomWords[0], tokenCounter, lastWinnerTokenId);
            address owner = ownerOf(tokenId);
            lastWinnerTokenId = tokenId;
            winnerExtracted = true;
            emit WinnerExtracted(requestId, tokenId, owner);

        } else {

            require(requestIdToVechileType[requestId] == 0 || requestIdToVechileType[requestId] > 3, "request vehicle type not found");
            require(requestIdToSender[requestId] != address(0x0), "request sender not found");
            uint8 vehicleType = requestIdToVechileType[requestId];
            address nftOwner = requestIdToSender[requestId];
            uint256 newTokenId = tokenCounter;
            string memory tokenURI = extractTokenURI(randomWords[0], vehicleType);

            _mint(nftOwner, newTokenId);
            _setTokenURI(newTokenId, tokenURI);
            
            requestIdToTokenId[requestId] = newTokenId;
            tokenCounter = tokenCounter + 1;
            emit NFTCreated(newTokenId, randomWords[0]);

        }
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords, bool winner) {
        require(requests[_requestId].exists, "request not found");
        RequestStatus memory request = requests[_requestId];
        return (request.fulfilled, request.randomWords, request.winner);
    }
}