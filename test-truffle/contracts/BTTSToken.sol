// //snapshot of version from 2018-02-09 as truffle need the contract to be in the correct folder for compilation
pragma solidity ^0.4.18;


import "./Owned.sol";
import "./BTTSLib.sol";




// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contracts that can have tokens approved, and then a function execute
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Interface v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSTokenInterface is ERC20Interface {
    uint public constant bttsVersion = 100;

    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
    enum CheckResult {
        Success,                           // 0 Success
        NotTransferable,                   // 1 Tokens not transferable yet
        AccountLocked,                     // 2 Account locked
        SignerMismatch,                    // 3 Mismatch in signing account
        AlreadyExecuted,                   // 4 Transfer already executed
        InsufficientApprovedTokens,        // 5 Insufficient approved tokens
        InsufficientApprovedTokensForFees, // 6 Insufficient approved tokens for fees
        InsufficientTokens,                // 7 Insufficient tokens
        InsufficientTokensForFees,         // 8 Insufficient tokens for fees
        OverflowError                      // 9 Overflow error
    }
}




// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Token Factory v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSToken is BTTSTokenInterface {
    using BTTSLib for BTTSLib.Data;

     BTTSLib.Data data;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function BTTSToken(address owner, string symbol, string name, uint8 decimals, uint initialSupply, bool mintable, bool transferable) public {
        data.init(owner, symbol, name, decimals, initialSupply, mintable, transferable);
    }

    // ------------------------------------------------------------------------
    // Ownership
    // ------------------------------------------------------------------------
    function owner() public view returns (address) {
        return data.owner;
    }
    function newOwner() public view returns (address) {
        return data.newOwner;
    }
    function transferOwnership(address _newOwner) public {
        data.transferOwnership(_newOwner);
    }
    function acceptOwnership() public {
        data.acceptOwnership();
    }
    function transferOwnershipImmediately(address _newOwner) public {
        data.transferOwnershipImmediately(_newOwner);
    }

    // ------------------------------------------------------------------------
    // Token
    // ------------------------------------------------------------------------
    function symbol() public view returns (string) {
        return data.symbol;
    }
    function name() public view returns (string) {
        return data.name;
    }
    function decimals() public view returns (uint8) {
        return data.decimals;
    }

    // ------------------------------------------------------------------------
    // Minting and management
    // ------------------------------------------------------------------------
    function minter() public view returns (address) {
        return data.minter;
    }
    function setMinter(address _minter) public {
        data.setMinter(_minter);
    }
    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success) {
        return data.mint(tokenOwner, tokens, lockAccount);
    }
    function unlockAccount(address tokenOwner) public {
        return data.unlockAccount(tokenOwner);
    }
    function mintable() public view returns (bool) {
        return data.mintable;
    }
    function transferable() public view returns (bool) {
        return data.transferable;
    }
    function disableMinting() public {
        data.disableMinting();
    }
    function enableTransfers() public {
        data.enableTransfers();
    }

    // ------------------------------------------------------------------------
    // Other functions
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
        return data.transferAnyERC20Token(tokenAddress, tokens);
    }

    // ------------------------------------------------------------------------
    // Don't accept ethers
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Token functions
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return data.totalSupply - data.balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return data.balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return data.allowed[tokenOwner][spender];
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        return data.transfer(to, tokens);
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        return data.approve(spender, tokens);
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        return data.transferFrom(from, to, tokens);
    }
    function approveAndCall(address spender, uint tokens, bytes _data) public returns (bool success) {
        success = data.approveAndCall(this, spender, tokens, _data);
    }

    // ------------------------------------------------------------------------
    // Signed function
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedTransferHash(address(this), tokenOwner, to, tokens, fee, nonce);
    }
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedTransferCheck(address(this), tokenOwner, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedTransfer(address(this), tokenOwner, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedApproveHash(address(this), tokenOwner, spender, tokens, fee, nonce);
    }
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedApproveCheck(address(this), tokenOwner, spender, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedApprove(address(this), tokenOwner, spender, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedTransferFromHash(address(this), spender, from, to, tokens, fee, nonce);
    }
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedTransferFromCheck(address(this), spender, from, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedTransferFrom(address(this), spender, from, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedApproveAndCallHash(address(this), tokenOwner, spender, tokens, _data, fee, nonce);
    }
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedApproveAndCallCheck(address(this), tokenOwner, spender, tokens, _data, fee, nonce, sig, feeAccount);
    }
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedApproveAndCall(address(this), tokenOwner, spender, tokens, _data, fee, nonce, sig, feeAccount);
    }
 }
