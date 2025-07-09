# moove-collection
<h3>Moove NFT Italy Collection per Start2Impact University</h3>

>Il progetto **moove-collection** contiene un contratto che si occupa di gestire gli NFT e la lotteria Moove. <br>
Il contratto ha il principale compito di mintare nuovi MooveNFT e consegnarli agli utenti, dando loro la possibilità di scambiarli.<br>
Il proprietario del contratto ha inoltre la possibilità di far partire la lotteria Moove ed estrarre l'NFT vincente.
I contratti sono stati creati, testati e deployati per mezzo di hardhat:
>
> - **/contracts** (folder): cartella contenente il contratto MooveManageContract che estende i contratti ERC721URIStorage e VRFConsumerBaseV2Plus: dettagli di seguito <br>
> - **/ignition** (folder): cartella contenente le istruzioni di deploy per l'ambiente hardhat. <br>
> - **hardhat.config.ts** (file): file di configurazione di hardhat, compilatore e network sono modificabili da questo file <br>
> - **package.json** (file): dipendenze del progetto <br>
><br>

>Come anticipato il contratto MooveManageContract estende due contratti:
> - **ERC721URIStorage** (OpenZeppelin contract): Contratto base per l'estensione del protocollo ERC721 che, oltre a garantire il minting e lo scambio di NFT, <br>
tramite l'implementazione del metodo _setTokenUri, permette l'inserimento di tokenURI personalizzati. <br>
> - **VRFConsumerBaseV2Plus** (Chainlink contract): Contratto base in grado di comunicare con i servizi Chainlink VRF: viene usato da Moove per ricevere numeri random verificati sulla base della quale viene scelto sia il tokenURI degli NFT mintati sia il tokenID vincitore della lotteria Moove. <br>


<h3> Compilazione </h3>

>*npx hardhat compile*

<h3> Test </h3>

>*npx hardhat test test\tst_\<nomeContratto>.ts*

<h3> Deploy </h3>

La rete di testnet configurata è Sepolia, è possibile configurare un'altra rete nel file hardhat.config.ts. Per il deploy su Sepolia Testnet eseguire

>npx hardhat ignition deploy ./ignition/modules/\<NomeContratto>.ts --network sepolia --reset



