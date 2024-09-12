import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VRF_SUBSCRIPTION_ID = "83197804157676353799599244805480243097604781785655240927128257511306231171104";
const MAX_SUPPLY = 120;
const CREATION_FEE = 0;

const MooveNFTModule = buildModule("MooveNFTModule", (m) => {
  const subscription_id = m.getParameter("subscriptionId", VRF_SUBSCRIPTION_ID);
  const mooveNFTModule = m.contract("MooveNFT", [subscription_id, MAX_SUPPLY, CREATION_FEE]);

  return { mooveNFTModule };
});

export default MooveNFTModule;
