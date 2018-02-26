pragma solidity ^0.4.18;

import "./BTTSTokenInterface.sol";
import "./ApproveAndCallFallBack.sol";


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Library v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------

//library BTTSLib 
contract BTTSToken is BTTSTokenInterface {
    Data private data;
    struct Data {
        bool initialised;

        // Ownership
        address owner;
        address newOwner;

        // Minting and managem ent
        address minter;
        bool mintable;
        bool transferable;
        mapping(address => bool) accountLocked;

        // Token
        string symbol;
        string name;
        uint8 decimals;
        uint totalSupply;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowed;
        mapping(address => uint) nextNonce;
    }

    function getOwner() public view returns (address) {
        return data.owner;
    }
    function getDecimals() public view returns (uint8) {
        return data.decimals;
    }
    function getMintable() public view returns (bool) {
        return data.mintable;
    }
    function getTransferable() public view returns (bool) {
        return data.transferable;
    }

    // ------------------------------------------------------------------------
    // Constants
    // ------------------------------------------------------------------------
    uint public constant bttsVersion = 110;
    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    // ------------------------------------------------------------------------
    // Event
    // ------------------------------------------------------------------------
    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);


    // ------------------------------------------------------------------------
    // Initialisation
    // ------------------------------------------------------------------------
    //function init(Data storage self, address owner, string symbol, string name, uint8 decimals, uint initialSupply, bool mintable, bool transferable) public {
    function init(address owner, string symbol, string name, uint8 decimals, uint initialSupply, bool mintable, bool transferable) public {
        require(data.initialised == false);
        //if (data.initialised == false) revert();  //require(Data.initialised == false);
        data.initialised = true;
        data.owner = owner;
        data.symbol = symbol;
        data.name = name;
        data.decimals = decimals;
        if (initialSupply > 0) {
            data.balances[data.owner] = initialSupply;
            data.totalSupply = initialSupply;
            Mint(data.owner, initialSupply, false);
            Transfer(address(0), data.owner, initialSupply);
        }
        data.mintable = mintable;
        data.transferable = transferable;
    }

    // ------------------------------------------------------------------------
    // Safe maths, inspired by OpenZeppelin
    // ------------------------------------------------------------------------
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    // ------------------------------------------------------------------------
    // Ownership
    // ------------------------------------------------------------------------
    function transferOwnership( address newOwner) public {
        require(msg.sender == data.owner);
        data.newOwner = newOwner;
    }
    function acceptOwnership( ) public {
        require(msg.sender == data.newOwner);
        OwnershipTransferred(data.owner, data.newOwner);
        data.owner = data.newOwner;
        data.newOwner = address(0);
    }
    function transferOwnershipImmediately(  address newOwner) public {
        require(msg.sender == data.owner);
        OwnershipTransferred(data.owner, newOwner);
        data.owner = newOwner;
        data.newOwner = address(0);
    }

    // ------------------------------------------------------------------------
    // Minting and management
    // ------------------------------------------------------------------------
    function setMinter( address minter) public {
        require(msg.sender == data.owner);
        require(data.mintable);
        MinterUpdated(data.minter, minter);
        data.minter = minter;
    }
    function mint( address tokenOwner, uint tokens, bool lockAccount) public returns (bool success) {
        require(data.mintable);
        require(msg.sender == data.minter || msg.sender == data.owner);
        if (lockAccount) {
            data.accountLocked[tokenOwner] = true;
        }
        data.balances[tokenOwner] = safeAdd(data.balances[tokenOwner], tokens);
        data.totalSupply = safeAdd(data.totalSupply, tokens);
        Mint(tokenOwner, tokens, lockAccount);
        Transfer(address(0), tokenOwner, tokens);
        return true;
    }
    function unlockAccount(address tokenOwner) public {
        require(msg.sender == data.owner);
        require(data.accountLocked[tokenOwner]);
        data.accountLocked[tokenOwner] = false;
        AccountUnlocked(tokenOwner);
    }
    function disableMinting() public {
        require(data.mintable);
        require(msg.sender == data.minter || msg.sender == data.owner);
        data.mintable = false;
        if (data.minter != address(0)) {
            MinterUpdated(data.minter, address(0));
            data.minter = address(0);
        }
        MintingDisabled();
    }
    function enableTransfers() public {
        require(msg.sender == data.owner);
        require(!data.transferable);
        data.transferable = true;
        TransfersEnabled();
    }

    // ------------------------------------------------------------------------
    // Other functions
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
        require(msg.sender == data.owner);
        return ERC20Interface(tokenAddress).transfer(data.owner, tokens);
    }

    // ------------------------------------------------------------------------
    // ecrecover from a signature rather than the signature in parts [v, r, s]
    // The signature format is a compact form {bytes32 r}{bytes32 s}{uint8 v}.
    // Compact means, uint8 is not padded to 32 bytes.
    //
    // An invalid signature results in the address(0) being returned, make
    // sure that the returned result is checked to be non-zero for validity
    //
    // Parts from https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    // ------------------------------------------------------------------------
    function ecrecoverFromSig(bytes32 hash, bytes sig) public pure returns (address recoveredAddress) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) return address(0);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            // Here we are loading the last 32 bytes. We exploit the fact that 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))
        }
        // Albeit non-transactional signatures are not specified by the YP, one would expect it to match the YP range of [27, 28]
        // geth uses [0, 1] and some clients have followed. This might change, see https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27) {
          v += 27;
        }
        if (v != 27 && v != 28) return address(0);
        return ecrecover(hash, v, r, s);
    }

    // ------------------------------------------------------------------------
    // Get CheckResult message
    // ------------------------------------------------------------------------
    function getCheckResultMessage(BTTSTokenInterface.CheckResult result) public pure returns (string) {
        if (result == BTTSTokenInterface.CheckResult.Success) {
            return "Success";
        } else if (result == BTTSTokenInterface.CheckResult.NotTransferable) {
            return "Tokens not transferable yet";
        } else if (result == BTTSTokenInterface.CheckResult.AccountLocked) {
            return "Account locked";
        } else if (result == BTTSTokenInterface.CheckResult.SignerMismatch) {
            return "Mismatch in signing account";
        } else if (result == BTTSTokenInterface.CheckResult.InvalidNonce) {
            return "Invalid nonce";
        } else if (result == BTTSTokenInterface.CheckResult.InsufficientApprovedTokens) {
            return "Insufficient approved tokens";
        } else if (result == BTTSTokenInterface.CheckResult.InsufficientApprovedTokensForFees) {
            return "Insufficient approved tokens for fees";
        } else if (result == BTTSTokenInterface.CheckResult.InsufficientTokens) {
            return "Insufficient tokens";
        } else if (result == BTTSTokenInterface.CheckResult.InsufficientTokensForFees) {
            return "Insufficient tokens for fees";
        } else if (result == BTTSTokenInterface.CheckResult.OverflowError) {
            return "Overflow error";
        } else {
            return "Unknown error";
        }
    }

    // ------------------------------------------------------------------------
    // Token functions
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        // Owner and minter can move tokens before the tokens are transferable
        require(data.transferable || (data.mintable && (msg.sender == data.owner || msg.sender == data.minter)));
        require(!data.accountLocked[msg.sender]);
        data.balances[msg.sender] = safeSub(data.balances[msg.sender], tokens);
        data.balances[to] = safeAdd(data.balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        require(!data.accountLocked[msg.sender]);
        data.allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(data.transferable);
        require(!data.accountLocked[from]);
        data.balances[from] = safeSub(data.balances[from], tokens);
        data.allowed[from][msg.sender] = safeSub(data.allowed[from][msg.sender], tokens);
        data.balances[to] = safeAdd(data.balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }
    function approveAndCall(address spender, uint tokens, bytes dataBytes) public returns (bool success) {
        require(!data.accountLocked[msg.sender]);
        data.allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), dataBytes);
        return true;
    }

    // ------------------------------------------------------------------------
    // Signed function
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        hash = keccak256(signedTransferSig, address(this), tokenOwner, to, tokens, fee, nonce);
    }
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!data.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedTransferHash(tokenOwner, to, tokens, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (data.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (data.nextNonce[tokenOwner] != nonce) return BTTSTokenInterface.CheckResult.InvalidNonce;
        uint total = safeAdd(tokens, fee);
        if (data.balances[tokenOwner] < tokens) return BTTSTokenInterface.CheckResult.InsufficientTokens;
        if (data.balances[tokenOwner] < total) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (data.balances[to] + tokens < data.balances[to]) return BTTSTokenInterface.CheckResult.OverflowError;
        if (data.balances[feeAccount] + fee < data.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(data.transferable);
        bytes32 hash = signedTransferHash(tokenOwner, to, tokens, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(keccak256(signingPrefix, hash), sig));
        require(!data.accountLocked[tokenOwner]);
        require(data.nextNonce[tokenOwner] == nonce);
        data.nextNonce[tokenOwner] = nonce + 1;
        data.balances[tokenOwner] = safeSub(data.balances[tokenOwner], tokens);
        data.balances[to] = safeAdd(data.balances[to], tokens);
        Transfer(tokenOwner, to, tokens);
        data.balances[tokenOwner] = safeSub(data.balances[tokenOwner], fee);
        data.balances[feeAccount] = safeAdd(data.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        return true;
    }
    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        hash = keccak256(signedApproveSig, address(this), tokenOwner, spender, tokens, fee, nonce);
    }
    function signedApproveCheck(   address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!data.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedApproveHash(tokenOwner, spender, tokens, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (data.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (data.nextNonce[tokenOwner] != nonce) return BTTSTokenInterface.CheckResult.InvalidNonce;
        if (data.balances[tokenOwner] < fee) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (data.balances[feeAccount] + fee < data.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(data.transferable);
        bytes32 hash = signedApproveHash(tokenOwner, spender, tokens, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(keccak256(signingPrefix, hash), sig));
        require(!data.accountLocked[tokenOwner]);
        require(data.nextNonce[tokenOwner] == nonce);
        data.nextNonce[tokenOwner] = nonce + 1;
        data.allowed[tokenOwner][spender] = tokens;
        Approval(tokenOwner, spender, tokens);
        data.balances[tokenOwner] = safeSub(data.balances[tokenOwner], fee);
        data.balances[feeAccount] = safeAdd(data.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        return true;
    }
    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        hash = keccak256(signedTransferFromSig, address(this), spender, from, to, tokens, fee, nonce);
    }
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!data.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedTransferFromHash(spender, from, to, tokens, fee, nonce);
        if (spender == address(0) || spender != ecrecoverFromSig(keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (data.accountLocked[from]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (data.nextNonce[spender] != nonce) return BTTSTokenInterface.CheckResult.InvalidNonce;
        uint total = safeAdd(tokens, fee);
        if (data.allowed[from][spender] < tokens) return BTTSTokenInterface.CheckResult.InsufficientApprovedTokens;
        if (data.allowed[from][spender] < total) return BTTSTokenInterface.CheckResult.InsufficientApprovedTokensForFees;
        if (data.balances[from] < tokens) return BTTSTokenInterface.CheckResult.InsufficientTokens;
        if (data.balances[from] < total) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (data.balances[to] + tokens < data.balances[to]) return BTTSTokenInterface.CheckResult.OverflowError;
        if (data.balances[feeAccount] + fee < data.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(data.transferable);
        bytes32 hash = signedTransferFromHash(spender, from, to, tokens, fee, nonce);
        require(spender != address(0) && spender == ecrecoverFromSig(keccak256(signingPrefix, hash), sig));
        require(!data.accountLocked[from]);
        require(data.nextNonce[spender] == nonce);
        data.nextNonce[spender] = nonce + 1;
        data.balances[from] = safeSub(data.balances[from], tokens);
        data.allowed[from][spender] = safeSub(data.allowed[from][spender], tokens);
        data.balances[to] = safeAdd(data.balances[to], tokens);
        Transfer(from, to, tokens);
        data.balances[from] = safeSub(data.balances[from], fee);
        data.allowed[from][spender] = safeSub(data.allowed[from][spender], fee);
        data.balances[feeAccount] = safeAdd(data.balances[feeAccount], fee);
        Transfer(from, feeAccount, fee);
        return true;
    }
    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes dataBytes, uint fee, uint nonce) public view returns (bytes32 hash) {
        hash = keccak256(signedApproveAndCallSig, address(this), tokenOwner, spender, tokens, dataBytes, fee, nonce);
    }
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes dataBytes, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!data.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedApproveAndCallHash(tokenOwner, spender, tokens, dataBytes, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (data.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (data.nextNonce[tokenOwner] != nonce) return BTTSTokenInterface.CheckResult.InvalidNonce;
        if (data.balances[tokenOwner] < fee) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (data.balances[feeAccount] + fee < data.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes dataBytes, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(data.transferable);
        bytes32 hash = signedApproveAndCallHash(tokenOwner, spender, tokens, dataBytes, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(keccak256(signingPrefix, hash), sig));
        require(!data.accountLocked[tokenOwner]);
        require(data.nextNonce[tokenOwner] == nonce);
        data.nextNonce[tokenOwner] = nonce + 1;
        data.allowed[tokenOwner][spender] = tokens;
        Approval(tokenOwner, spender, tokens);
        data.balances[tokenOwner] = safeSub(data.balances[tokenOwner], fee);
        data.balances[feeAccount] = safeAdd(data.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        ApproveAndCallFallBack(spender).receiveApproval(tokenOwner, tokens, address(this), dataBytes);
        return true;
    }
}