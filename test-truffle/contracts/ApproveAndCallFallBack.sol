//interface for ApproveAndCallFallBack

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Contracts that can have tokens approved, and then a function executed
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
