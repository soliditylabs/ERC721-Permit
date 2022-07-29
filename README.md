# ERC721-permit

Package for implementing the ERC721 permit (EIP-4494). Unaudited, use at own risk.

## Installation

1. Install the package via NPM:

```bash
$ npm install @soliditylabs/erc721-permit --save-dev
```

Or Yarn:

```bash
$ yarn add @soliditylabs/erc721-permit --dev
```

2. Import it into your ERC-721 contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721Permit } from "@soliditylabs/erc721-permit/contracts/ERC721Permit.sol";

contract NFTMock is ERC721Permit("Mock721", "MOCK") {
  uint256 private _lastTokenId;

  function mint() public {
    _mint(msg.sender, ++_lastTokenId);
  }

  function safeTransferFromWithPermit(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data,
    uint256 deadline,
    bytes memory signature
  ) external {
    _permit(msg.sender, tokenId, deadline, signature);
    safeTransferFrom(from, to, tokenId, _data);
  }
}

```

## Running tests

1. Clone the repository

```bash
$ git clone https://github.com/soliditylabs/ERC721-Permit
```

2. Install the dependencies

```bash
$ cd ERC721-Permit
$ npm install
```

3. Run Hardhat Node

```bash
$ npx hardhat node
```

4. Run tests

```bash
$ npm test
```
