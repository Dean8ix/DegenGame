import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const DegenGameModule = buildModule("DegenGameModule", (m) => {

  const degenGame = m.contract("DegenGame");

  return { degenGame };
});

export default DegenGameModule;
