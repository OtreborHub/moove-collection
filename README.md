# moove-collection
<h3>Moove NFT Italy Collection per Start2Impact University</h3>


> Si immagina lo scenario in cui ogni utente che utilizza un mezzo di trasporto Moove, può scannerizzare il QRCode presente sul mezzo, e viene reindirizzato ad un applicativo front-end
che si occuperà di chiamare la funzione di minting del contratto. Dallo stesso applicativo, l'owner può modificare la fee di creazione degli NFT, il numero massimo di NFT mintabili (maxSupply), prelevare denaro dal contratto e più importante, avviare il meccanismo della lotteria Moove.

>Il progetto **moove-collection** contiene il contratto che si occupa di gestire gli NFT e la lotteria Moove. <br>
Il contratto ha il principale compito di mintare nuovi MooveNFT e consegnarli agli utenti, dando loro la possibilità di scambiarli.<br>
Il proprietario del contratto ha inoltre la possibilità di far partire la lotteria Moove ed estrarre l'NFT vincente.
I contratti sono stati creati, testati e deployati per mezzo di hardhat:
>
> - **/contracts** (folder): cartella contenente il contratto **MooveManageContract** che estende i contratti ERC721URIStorage e VRFConsumerBaseV2Plus: dettagli di seguito <br>
> - **/ignition** (folder): cartella contenente le istruzioni di deploy per l'ambiente hardhat. <br>
> - **hardhat.config.ts** (file): file di configurazione di hardhat, compilatore e network sono modificabili da questo file <br>
> - **package.json** (file): dipendenze del progetto <br>

>Come anticipato il contratto **MooveManageContract** estende due contratti:
> - **ERC721URIStorage** (contratto OpenZeppelin): contratto base per l'estensione del protocollo ERC721 che, oltre a garantire il minting e lo scambio di NFT,
tramite l'implementazione del metodo _setTokenUri, permette l'inserimento di tokenURI personalizzati. <br>
> - **VRFConsumerBaseV2Plus** (contratto Chainlink): contratto base in grado di comunicare con i servizi Chainlink VRF previa sottoscrizione: viene usato da Moove per ricevere numeri random verificati sulla base della quale viene scelto sia il tokenURI degli NFT mintati sia il tokenID vincitore della lotteria Moove. <br>


<h3> Compilazione </h3>

>*npx hardhat compile*

<h3> Test </h3>

>*npx hardhat test test\tst_\<nomeContratto>.ts*

<h3> Deploy </h3>

La rete di testnet configurata è Sepolia, è possibile configurare un'altra rete nel file hardhat.config.ts. Per il deploy su Sepolia Testnet eseguire

>npx hardhat ignition deploy ./ignition/modules/\<NomeContratto>.ts --network sepolia --reset

Dopo il deploy del contratto è necessario aggiungere il contratto stesso tra consumer della subscription di Chainlink per poter chiamare i servizi VRF.

<h3> Contratto </h3>
Sepolia Etherscan: https://sepolia.etherscan.io/address/0xF809C38F785af25E5CF6633fa82955ea56a6adf4

