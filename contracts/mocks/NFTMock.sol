// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../ERC721Permit.sol";

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
