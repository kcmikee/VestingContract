import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x836207E3679531e2481Cf8d85dfB1ac75baf542C";

const VestingModule = buildModule("VestingModule", (m) => {
  const vesting = m.contract("VestingContract", [tokenAddress]);

  return { vesting };
});

export default VestingModule;

// Deployed VestingContract: 0x96cf7DD655D0d366F05E38fB6fB71DFaa9180551
