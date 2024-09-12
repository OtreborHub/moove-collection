// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MooveUtilsV1 {

  uint16 maxNumber = 999;
  uint8 splitCase = 5;
  uint16 refCase = maxNumber/splitCase;

  //Vengono usate le ultime 3 cifre e divisi i casi per le 5 fasce di valori calcolate 
  function extractTokenURI(uint256 randomNumber) internal view returns(string memory tokenURI){
    uint256 extractedNumber = randomNumber % 1000;
    if(extractedNumber <= refCase){
      tokenURI = "https://ipfs.io/ipfs/QmciRexU67eTMQaMYJuR7ZeGzmDdbeekWQ4wUAM6v5BbNk?filename=MC1_TurinInfo.json";
    } else
    if(extractedNumber <= 2*refCase){
      tokenURI = "https://ipfs.io/ipfs/QmbR7ADgbhYf9j7xVaRqjSQ1wZKu4oSiENfu1QozXKFJ7P?filename=MC1_MilanInfo.json";
    } else 
    if(extractedNumber <= 3*refCase){
      tokenURI = "https://ipfs.io/ipfs/QmUeANYEVTKR6WUzqZ2KpFAZLPnAQRnN1XjhfAu294VaQa?filename=MC1_FlorenceInfo.json";
    } else 
    if(extractedNumber <= 4*refCase){
      tokenURI = "https://ipfs.io/ipfs/QmTBJ86dS5nHGKzZ52Wi7d1YzNRP9uYGZaR6ZokCixtDox?filename=MC1_BolognaInfo.json";
    } else {
      tokenURI = "https://ipfs.io/ipfs/QmQSMNEySFNH6st7veUbTUJc4qKphTDyNv54ff7yuE9MZM?filename=MC1_VeniceInfo.json";
    }
  }

  function extractWinner(uint256 randomNumber, uint256 tokenCounter) internal pure returns (uint256 winnerTokenID) {
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
        winnerTokenID = (extractedNumber / groupSize) + 1;

        // Assicura che il tokenID non superi tokenCounter
        if (winnerTokenID > tokenCounter) {
            winnerTokenID = tokenCounter;
        }
    }

}