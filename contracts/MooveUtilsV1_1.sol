// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MooveUtilsV1_1 {

  uint16 maxNumber = 999;
  uint8 splitCase = 5;
  uint16 refCase = maxNumber/splitCase;

  //Vengono usate le ultime 3 cifre e divisi i casi per le 5 fasce di valori calcolate 
  function extractTokenURI(uint256 randomNumber, uint8 vehicleType) internal view returns(string memory tokenURI){
    if(vehicleType == 3){
      tokenURI = "https://ipfs.io/ipfs/QmQKj8cxn3kkfKhk6CFfLQMBA4FQgvXnx1Qwn4yHymsSCF";
    }else {
      uint256 extractedNumber = randomNumber % 1000;
      if(extractedNumber <= refCase){
        tokenURI = "https://ipfs.io/ipfs/QmZSLSC2RcnBXykj4rkprYowpWqk8Xt1jrZBt8HQtfLX8Q";
      } else
      if(extractedNumber <= 2*refCase){
        tokenURI = "https://ipfs.io/ipfs/QmZHG2jmR65SaJZ9YKjRMLyFXBcPcFY3Y37WC7xTgkKuVP";
      } else 
      if(extractedNumber <= 3*refCase){
        tokenURI = "https://ipfs.io/ipfs/QmaZSunX1wxU1Atvt9QzWcwPByketPbyoT1ENUgD9r9Eb2?filename=MC1_FirenzeInfo.json";
      } else 
      if(extractedNumber <= 4*refCase){
        tokenURI = "https://ipfs.io/ipfs/QmdapCrGS8SoF9zAqFSLeSaxF37krPPKbX9p7Vcb5uuMPu?filename=MC1_BolognaInfo.json";
      } else {
        tokenURI = "https://ipfs.io/ipfs/QmdWq2pyhqANBthZRsPsfEtLqvRxVaSRSPPUyEUWjfVVjH?filename=MC1_RomaInfo.json";
      }
    }
  }

  function extractWinner(uint256 randomNumber, uint256 tokenCounter, uint256 lastWinnerTokenId) internal pure returns (uint256 winnerTokenId) {
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

    winnerTokenId = avoidSameWinner(tokenCounter, winnerTokenId, lastWinnerTokenId);
  }

  //Metodo creato per evitare che venga estratto due volte lo stesso tokenId e 
  //raddoppia la possibilità di estrazione dei tokenId vicini all'ultimo estratto.
  function avoidSameWinner(uint256 tokenCounter, uint256 winnerTokenId, uint256 lastWinnerTokenId) private pure  returns (uint256) {
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

