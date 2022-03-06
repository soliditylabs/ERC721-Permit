// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IERC721Permit.sol";

contract ERC721Permit is IERC721Permit, ERC721, EIP712 {
  using Counters for Counters.Counter;

  mapping(uint256 => Counters.Counter) private _nonces;

  // solhint-disable-next-line var-name-mixedcase
  bytes32 private immutable _PERMIT_TYPEHASH =
    keccak256(
      "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
    );

  constructor(string memory name, string memory symbol)
    ERC721(name, symbol)
    EIP712(name, "1")
  {
    this;
  }

  function nonces(uint256 tokenId)
    external
    view
    virtual
    override
    returns (uint256)
  {
    return _nonces[tokenId].current();
  }

  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view override returns (bytes32) {
    return _domainSeparatorV4();
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      interfaceId == type(IERC721Permit).interfaceId || // 0x5604e225
      super.supportsInterface(interfaceId);
  }

  function permit(
    address spender,
    uint256 tokenId,
    uint256 deadline,
    bytes memory signature
  ) external override {
    _permit(spender, tokenId, deadline, signature);
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    _nonces[tokenId].increment();
    super._transfer(from, to, tokenId);
  }

  function _permit(
    address spender,
    uint256 tokenId,
    uint256 deadline,
    bytes memory signature
  ) internal virtual {
    // solhint-disable-next-line not-rely-on-time
    require(block.timestamp <= deadline, "ERC721Permit: expired deadline");

    bytes32 structHash = keccak256(
      abi.encode(
        _PERMIT_TYPEHASH,
        spender,
        tokenId,
        _nonces[tokenId].current(),
        deadline
      )
    );
    bytes32 hash = _hashTypedDataV4(structHash);

    (address signer, ) = ECDSA.tryRecover(hash, signature);
    bool isValidEOASignature = signer != address(0) &&
      _isApprovedOrOwner(signer, tokenId);

    require(
      isValidEOASignature ||
        _isValidContractERC1271Signature(ownerOf(tokenId), hash, signature) ||
        _isValidContractERC1271Signature(getApproved(tokenId), hash, signature),
      "ERC721Permit: invalid signature"
    );

    _approve(spender, tokenId);
  }

  function _isValidContractERC1271Signature(
    address signer,
    bytes32 hash,
    bytes memory signature
  ) private view returns (bool) {
    (bool success, bytes memory result) = signer.staticcall(
      abi.encodeWithSelector(
        IERC1271.isValidSignature.selector,
        hash,
        signature
      )
    );
    return (success &&
      result.length == 32 &&
      abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
  }
}
