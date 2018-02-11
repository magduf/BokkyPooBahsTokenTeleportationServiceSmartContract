pragma solidity ^0.4.18;

import "./BTTSTokenFactory.sol";
//import "./sol";

// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Library v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
library BTTSLib {

    struct Data {
        // Ownership
        address owner;
        address newOwner;

        // Minting and management
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
        mapping(address => mapping(bytes32 => bool)) executed;
    }


    // ------------------------------------------------------------------------
    // Constants
    // ------------------------------------------------------------------------
    uint public constant bttsVersion = 100;
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
    // Ownership
    // ------------------------------------------------------------------------
    function transferOwnership(Data storage self, address newOwner) public {
        require(msg.sender == self.owner);
        self.newOwner = newOwner;
    }
    function acceptOwnership(Data storage self) public {
        require(msg.sender == self.newOwner);
        OwnershipTransferred(self.owner, self.newOwner);
        self.owner = self.newOwner;
        self.newOwner = address(0);
    }
    function transferOwnershipImmediately(Data storage self, address newOwner) public {
        require(msg.sender == self.owner);
        OwnershipTransferred(self.owner, newOwner);
        self.owner = newOwner;
        self.newOwner = address(0);
    }

    // ------------------------------------------------------------------------
    // Safe maths
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
    // Initialisation
    // ------------------------------------------------------------------------
    function init(Data storage self, address owner, string symbol, string name, uint8 decimals, uint initialSupply, bool mintable, bool transferable) public {
        require(self.owner == address(0));
        self.owner = owner;
        self.symbol = symbol;
        self.name = name;
        self.decimals = decimals;
        if (initialSupply > 0) {
            self.balances[owner] = initialSupply;
            self.totalSupply = initialSupply;
            Mint(self.owner, initialSupply, false);
            Transfer(address(0), self.owner, initialSupply);
        }
        self.mintable = mintable;
        self.transferable = transferable;
    }





    // ------------------------------------------------------------------------
    // Minting and management
    // ------------------------------------------------------------------------
    function setMinter(Data storage self, address minter) public {
        require(msg.sender == self.owner);
        require(self.mintable);
        MinterUpdated(self.minter, minter);
        self.minter = minter;
    }
    function mint(Data storage self, address tokenOwner, uint tokens, bool lockAccount) public returns (bool success) {
        require(self.mintable);
        require(msg.sender == self.minter || msg.sender == self.owner);
        if (lockAccount) {
            self.accountLocked[tokenOwner] = true;
        }
        self.balances[tokenOwner] = safeAdd(self.balances[tokenOwner], tokens);
        self.totalSupply = safeAdd(self.totalSupply, tokens);
        Mint(tokenOwner, tokens, lockAccount);
        Transfer(address(0), tokenOwner, tokens);
        return true;
    }
    function unlockAccount(Data storage self, address tokenOwner) public {
        require(msg.sender == self.owner);
        require(self.accountLocked[tokenOwner]);
        self.accountLocked[tokenOwner] = false;
        AccountUnlocked(tokenOwner);
    }
    function disableMinting(Data storage self) public {
        require(self.mintable);
        require(msg.sender == self.minter || msg.sender == self.owner);
        self.mintable = false;
        if (self.minter != address(0)) {
            MinterUpdated(self.minter, address(0));
            self.minter = address(0);
        }
        MintingDisabled();
    }
    function enableTransfers(Data storage self) public {
        require(msg.sender == self.owner);
        require(!self.transferable);
        self.transferable = true;
        TransfersEnabled();
    }

    // ------------------------------------------------------------------------
    // Other functions
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(Data storage self, address tokenAddress, uint tokens) public returns (bool success) {
        require(msg.sender == self.owner);
        return ERC20Interface(tokenAddress).transfer(self.owner, tokens);
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
    function ecrecoverFromSig(Data storage /*self*/, bytes32 hash, bytes sig) public pure returns (address recoveredAddress) {
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
    function getCheckResultMessage(Data storage /*self*/, BTTSTokenInterface.CheckResult result) public pure returns (string) {
        if (result == BTTSTokenInterface.CheckResult.Success) {
            return "Success";
        } else if (result == BTTSTokenInterface.CheckResult.NotTransferable) {
            return "Tokens not transferable yet";
        } else if (result == BTTSTokenInterface.CheckResult.AccountLocked) {
            return "Account locked";
        } else if (result == BTTSTokenInterface.CheckResult.SignerMismatch) {
            return "Mismatch in signing account";
        } else if (result == BTTSTokenInterface.CheckResult.AlreadyExecuted) {
            return "Transfer already executed";
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
    function transfer(Data storage self, address to, uint tokens) public returns (bool success) {
        // Owner and minter can move tokens before the tokens are transferable 
        require(self.transferable || (self.mintable && (msg.sender == self.owner || msg.sender == self.minter)));
        require(!self.accountLocked[msg.sender]);
        self.balances[msg.sender] = safeSub(self.balances[msg.sender], tokens);
        self.balances[to] = safeAdd(self.balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(Data storage self, address spender, uint tokens) public returns (bool success) {
        require(!self.accountLocked[msg.sender]);
        self.allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(Data storage self, address from, address to, uint tokens) public returns (bool success) {
        require(self.transferable);
        require(!self.accountLocked[from]);
        self.balances[from] = safeSub(self.balances[from], tokens);
        self.allowed[from][msg.sender] = safeSub(self.allowed[from][msg.sender], tokens);
        self.balances[to] = safeAdd(self.balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }
    function approveAndCall(Data storage self, address tokenContract, address spender, uint tokens, bytes data) public returns (bool success) {
        require(!self.accountLocked[msg.sender]);
        self.allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, tokenContract, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Signed function
    // ------------------------------------------------------------------------
    function signedTransferHash(Data storage /*self*/, address tokenContract, address tokenOwner, address to, uint tokens, uint fee, uint nonce) public pure returns (bytes32 hash) {
        hash = keccak256(signedTransferSig, tokenContract, tokenOwner, to, tokens, fee, nonce);
    }
    function signedTransferCheck(Data storage self, address tokenContract, address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!self.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedTransferHash(self, tokenContract, tokenOwner, to, tokens, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (self.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (self.executed[tokenOwner][hash]) return BTTSTokenInterface.CheckResult.AlreadyExecuted;
        uint total = safeAdd(tokens, fee);
        if (self.balances[tokenOwner] < tokens) return BTTSTokenInterface.CheckResult.InsufficientTokens;
        if (self.balances[tokenOwner] < total) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (self.balances[to] + tokens < self.balances[to]) return BTTSTokenInterface.CheckResult.OverflowError;
        if (self.balances[feeAccount] + fee < self.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedTransfer(Data storage self, address tokenContract, address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(self.transferable);
        bytes32 hash = signedTransferHash(self, tokenContract, tokenOwner, to, tokens, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig));
        require(!self.accountLocked[tokenOwner]);
        require(!self.executed[tokenOwner][hash]);
        self.executed[tokenOwner][hash] = true;
        self.balances[tokenOwner] = safeSub(self.balances[tokenOwner], tokens);
        self.balances[to] = safeAdd(self.balances[to], tokens);
        Transfer(tokenOwner, to, tokens);
        self.balances[tokenOwner] = safeSub(self.balances[tokenOwner], fee);
        self.balances[feeAccount] = safeAdd(self.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        return true;
    }
    function signedApproveHash(Data storage /*self*/, address tokenContract, address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public pure returns (bytes32 hash) {
        hash = keccak256(signedApproveSig, tokenContract, tokenOwner, spender, tokens, fee, nonce);
    }
    function signedApproveCheck(Data storage self, address tokenContract, address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!self.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedApproveHash(self, tokenContract, tokenOwner, spender, tokens, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (self.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (self.executed[tokenOwner][hash]) return BTTSTokenInterface.CheckResult.AlreadyExecuted;
        if (self.balances[tokenOwner] < fee) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (self.balances[feeAccount] + fee < self.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedApprove(Data storage self, address tokenContract, address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(self.transferable);
        bytes32 hash = signedApproveHash(self, tokenContract, tokenOwner, spender, tokens, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig));
        require(!self.accountLocked[tokenOwner]);
        require(!self.executed[tokenOwner][hash]);
        self.executed[tokenOwner][hash] = true;
        self.allowed[tokenOwner][spender] = tokens;
        Approval(tokenOwner, spender, tokens);
        self.balances[tokenOwner] = safeSub(self.balances[tokenOwner], fee);
        self.balances[feeAccount] = safeAdd(self.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        return true;
    }
    function signedTransferFromHash(Data storage /*self*/, address tokenContract, address spender, address from, address to, uint tokens, uint fee, uint nonce) public pure returns (bytes32 hash) {
        hash = keccak256(signedTransferFromSig, tokenContract, spender, from, to, tokens, fee, nonce);
    }
    function signedTransferFromCheck(Data storage self, address tokenContract, address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!self.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedTransferFromHash(self, tokenContract, spender, from, to, tokens, fee, nonce);
        if (spender == address(0) || spender != ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (self.accountLocked[from]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (self.executed[spender][hash]) return BTTSTokenInterface.CheckResult.AlreadyExecuted;
        uint total = safeAdd(tokens, fee);
        if (self.allowed[from][spender] < tokens) return BTTSTokenInterface.CheckResult.InsufficientApprovedTokens;
        if (self.allowed[from][spender] < total) return BTTSTokenInterface.CheckResult.InsufficientApprovedTokensForFees;
        if (self.balances[from] < tokens) return BTTSTokenInterface.CheckResult.InsufficientTokens;
        if (self.balances[from] < total) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (self.balances[to] + tokens < self.balances[to]) return BTTSTokenInterface.CheckResult.OverflowError;
        if (self.balances[feeAccount] + fee < self.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedTransferFrom(Data storage self, address tokenContract, address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(self.transferable);
        bytes32 hash = signedTransferFromHash(self, tokenContract, spender, from, to, tokens, fee, nonce);
        require(spender != address(0) && spender == ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig));
        require(!self.accountLocked[from]);
        require(!self.executed[spender][hash]);
        self.executed[spender][hash] = true;
        self.balances[from] = safeSub(self.balances[from], tokens);
        self.allowed[from][spender] = safeSub(self.allowed[from][spender], tokens);
        self.balances[to] = safeAdd(self.balances[to], tokens);
        Transfer(from, to, tokens);
        self.balances[from] = safeSub(self.balances[from], fee);
        self.allowed[from][spender] = safeSub(self.allowed[from][spender], fee);
        self.balances[feeAccount] = safeAdd(self.balances[feeAccount], fee);
        Transfer(from, feeAccount, fee);
        return true;
    }
    function signedApproveAndCallHash(Data storage /*self*/, address tokenContract, address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce) public pure returns (bytes32 hash) {
        hash = keccak256(signedApproveAndCallSig, tokenContract, tokenOwner, spender, tokens, data, fee, nonce);
    }
    function signedApproveAndCallCheck(Data storage self, address tokenContract, address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (BTTSTokenInterface.CheckResult result) {
        if (!self.transferable) return BTTSTokenInterface.CheckResult.NotTransferable;
        bytes32 hash = signedApproveAndCallHash(self, tokenContract, tokenOwner, spender, tokens, data, fee, nonce);
        if (tokenOwner == address(0) || tokenOwner != ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig)) return BTTSTokenInterface.CheckResult.SignerMismatch;
        if (self.accountLocked[tokenOwner]) return BTTSTokenInterface.CheckResult.AccountLocked;
        if (self.executed[tokenOwner][hash]) return BTTSTokenInterface.CheckResult.AlreadyExecuted;
        if (self.balances[tokenOwner] < fee) return BTTSTokenInterface.CheckResult.InsufficientTokensForFees;
        if (self.balances[feeAccount] + fee < self.balances[feeAccount]) return BTTSTokenInterface.CheckResult.OverflowError;
        return BTTSTokenInterface.CheckResult.Success;
    }
    function signedApproveAndCall(Data storage self, address tokenContract, address tokenOwner, address spender, uint tokens, bytes data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        require(self.transferable);
        bytes32 hash = signedApproveAndCallHash(self, tokenContract, tokenOwner, spender, tokens, data, fee, nonce);
        require(tokenOwner != address(0) && tokenOwner == ecrecoverFromSig(self, keccak256(signingPrefix, hash), sig));
        require(!self.accountLocked[tokenOwner]);
        require(!self.executed[tokenOwner][hash]);
        self.executed[tokenOwner][hash] = true;
        self.allowed[tokenOwner][spender] = tokens;
        Approval(tokenOwner, spender, tokens);
        self.balances[tokenOwner] = safeSub(self.balances[tokenOwner], fee);
        self.balances[feeAccount] = safeAdd(self.balances[feeAccount], fee);
        Transfer(tokenOwner, feeAccount, fee);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, tokenContract, data);
        return true;
    }
}
