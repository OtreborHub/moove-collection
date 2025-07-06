// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract MooveManageContract is ERC721URIStorage, VRFConsumerBaseV2Plus {

    struct RequestStatus {
        bool fulfilled; 
        bool exists;
        uint256[] randomWords;
        bool winner;
    }

    uint256 private _tokenIds;
    uint256 public maxSupply;
    uint256 public creationFee;
    uint256 public lastWinnerTokenId = 0;

    // Chainlink VRF config
    address public vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    uint256 public subscriptionId;

    bytes32 private _keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private _callbackGasLimit = 500000;
    uint16 private _requestConfirmations = 3;
    uint32 private _numWords = 1;

    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => RequestStatus) public requests;

    event RandomNumberRequested(uint256 requestId);
    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    event WinnerExtracted(uint256 requestId, uint256 tokenId, address owner);

    constructor(uint256 _subscriptionId, uint256 _maxSupply, uint256 _creationFee)
        ERC721("VRF NFT", "VRFNFT")
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        maxSupply = _maxSupply;
        creationFee = _creationFee;
        subscriptionId = _subscriptionId;
    }

    function requestMint(uint8 dataType) public payable {
        require(_tokenIds < maxSupply, "Max supply reached");
        require(msg.value >= creationFee, "Insufficient fee");
        
        if(dataType == 3){
            _mintToken(msg.sender, 0, true);
        } else {

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: _keyHash,
                subId: subscriptionId,
                requestConfirmations: _requestConfirmations,
                callbackGasLimit: _callbackGasLimit,
                numWords: _numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        requestIdToSender[requestId] = msg.sender;

        emit RandomNumberRequested(requestId);
        }
    }

    function requestLotteryWinner() public payable onlyOwner {
        require(_tokenIds > 2, "No NFTs minted yet"); 

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: _keyHash,
                subId: subscriptionId,
                requestConfirmations: _requestConfirmations,
                callbackGasLimit: _callbackGasLimit,
                numWords: _numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requests[requestId] = RequestStatus({
            fulfilled: false,
            exists: true,
            randomWords: new uint256[](0),
            winner: true
        });

        emit RandomNumberRequested(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        address recipient = requestIdToSender[requestId];
        if(recipient == address(0) && requests[requestId].winner) {
           
            uint256 tokenId = extractWinner(randomWords[0], _tokenIds);
            address owner = ownerOf(tokenId);
            lastWinnerTokenId = tokenId;
            emit WinnerExtracted(requestId, tokenId, owner);

        } else {
            _mintToken(recipient, randomWords[0], false);
        }

    }

    function _selectTokenURI(uint256 randomNumber, bool specialType) internal pure returns (string memory) {
        if(specialType){
            return "https://bafybeigq3ahv6jwzql75rlqxh7wewj6km4me5hw65qbtj2uei3dqa2zl7i.ipfs.dweb.link?filename=ItalyInfo.json";
        } else if (randomNumber <= 20) {
            return "https://bafybeieqcq4wz2bqhdcnzqep5ysckso6ba27awoim4f2rjldnsh6n7eu5a.ipfs.dweb.link?filename=TurinInfo.json";
        } else if (randomNumber <= 40) {
            return "https://bafybeigupmkubyqmdcu2dgdwd4wy25hllzw55kptauh6k7lbdywhuq3qfa.ipfs.dweb.link?filename=MilanInfo.json";
        } else if (randomNumber <= 60) {
            return "https://bafybeihfpxevc7almmt6qa3hx5qyldncuczch5uoxwoaeuxjrgpoxoxgge.ipfs.dweb.link?filename=FlorenceInfo.json";
        } else if (randomNumber <= 80) {
            return "https://bafybeib5wafomsn2erdpmgo7uzaduawdpppa4aiivxjjomuszkbqgqitdy.ipfs.dweb.link?filename=BologneInfo.json";
        } else {
            return "https://bafybeifoe6kboc55kqqwq4g4gxnhbgogv55kxov6gb2dvw5o7445todhmq.ipfs.dweb.link?filename=RomeInfo.json";
        }
    }

    function _mintToken(address recipient, uint256 randomWord, bool specialType) private {
        require(recipient != address(0), "Request not found");

        uint256 randomNumber = (randomWord % 100) + 1;
        string memory tokenURI = _selectTokenURI(randomNumber, specialType);

        _tokenIds += 1;
        uint256 newItemId = _tokenIds;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit NFTMinted(recipient, newItemId, tokenURI);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setCreationFee(uint256 _creationFee) public onlyOwner {
        creationFee = _creationFee;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function extractWinner(uint256 randomNumber, uint256 tokenCounter) internal view returns (uint256 winnerTokenId) {
        uint256 digits = 1;
        uint256 tempTokenCounter = tokenCounter;

        // Conta il numero di cifre di tokenCounter
        while (tempTokenCounter > 0) {
            tempTokenCounter /= 10;
            digits++;
        }
        
        // Ottiene le ultime cifre significative del numero random
        uint256 extractedNumber = randomNumber % (10**digits);
        
        // Calcola la dimensione del gruppo
        uint256 groupSize = (10**digits + tokenCounter - 1) / tokenCounter;
        
        // Mappa il numero estratto al tokenID vincente
        winnerTokenId = (extractedNumber / groupSize) + 1;

        // Assicura che il tokenID non superi tokenCounter
        if (winnerTokenId > tokenCounter - 1) {
        winnerTokenId = tokenCounter - 1;
        }

        winnerTokenId = avoidSameWinner(tokenCounter, winnerTokenId);
    }

  //Metodo creato per evitare che venga estratto due volte lo stesso tokenId e 
  //raddoppia la possibilità di estrazione dei tokenId vicini all'ultimo estratto.
  function avoidSameWinner(uint256 tokenCounter, uint256 winnerTokenId) private view returns (uint256) {
    if(lastWinnerTokenId == winnerTokenId){
      if(lastWinnerTokenId == 0){
        winnerTokenId++;
      } else if (lastWinnerTokenId == tokenCounter - 1){
        winnerTokenId--;
      } else {
        //Se winnerTokenId pari assegna la vittoria al token successivo
        if(winnerTokenId % 2 == 0){
          winnerTokenId++;
        //Se winnerTokenId dispari assegna la vittoria al token precedente
        } else {
          winnerTokenId--;
        }
      }
    }
    return winnerTokenId;
  }
}