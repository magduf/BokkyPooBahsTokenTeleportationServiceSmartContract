pragma solidity ^0.4.18;


// import "./Owned.sol";
// import "./BTTSToken.sol";
// import "./BTTSTokenInterface.sol";
// import "./ERC20Interface.sol";

// // ----------------------------------------------------------------------------
// // BokkyPooBah's Token Teleportation Service v1.10
// //
// // https://github.com/bokkypoobah/BokkyPooBahsTokenTeleportationServiceSmartContract
// //
// // Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// // ----------------------------------------------------------------------------



// // ----------------------------------------------------------------------------
// // BokkyPooBah's Token Teleportation Service Token Factory v1.10
// //
// // Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// // ----------------------------------------------------------------------------
// contract BTTSTokenFactory is Owned {

//     // ------------------------------------------------------------------------
//     // Internal data
//     // ------------------------------------------------------------------------
//     mapping(address => bool) _verify;
//     address[] public deployedTokens;

//     // ------------------------------------------------------------------------
//     // Event
//     // ------------------------------------------------------------------------
//     event BTTSTokenListing(address indexed ownerAddress,
//         address indexed bttsTokenAddress,
//         string symbol, string name, uint8 decimals,
//         uint initialSupply, bool mintable, bool transferable);


//     // ------------------------------------------------------------------------
//     // Anyone can call this method to verify whether the bttsToken contract at
//     // the specified address was deployed using this factory
//     //
//     // Parameters:
//     //   tokenContract  the bttsToken contract address
//     //
//     // Return values:
//     //   valid          did this BTTSTokenFactory create the BTTSToken contract?
//     //   decimals       number of decimal places for the token contract
//     //   initialSupply  the token initial supply
//     //   mintable       is the token mintable after deployment?
//     //   transferable   are the tokens transferable after deployment?
//     // ------------------------------------------------------------------------
//     function verify(address tokenContract) public view returns (
//         bool    valid,
//         address owner,
//         uint    decimals,
//         bool    mintable,
//         bool    transferable
//     ) {
//         valid = _verify[tokenContract];
//         if (valid) {
//             BTTSTokenInterface t = BTTSTokenInterface(tokenContract);
//             owner        = t.owner();
//             decimals     = t.decimals();
//             mintable     = t.mintable();
//             transferable = t.transferable();
//         }
//     }


//     // ------------------------------------------------------------------------
//     // Any account can call this method to deploy a new BTTSToken contract.
//     // The owner of the BTTSToken contract will be the calling account
//     //
//     // Parameters:
//     //   symbol         symbol
//     //   name           name
//     //   decimals       number of decimal places for the token contract
//     //   initialSupply  the token initial supply
//     //   mintable       is the token mintable after deployment?
//     //   transferable   are the tokens transferable after deployment?
//     //
//     // For example, deploying a BTTSToken contract with `initialSupply` of
//     // 1,000.000000000000000000 tokens:
//     //   symbol         "ME"
//     //   name           "My Token"
//     //   decimals       18
//     //   initialSupply  10000000000000000000000 = 1,000.000000000000000000
//     //                  tokens
//     //   mintable       can tokens be minted after deployment?
//     //   transferable   are the tokens transferable after deployment?
//     //
//     // The BTTSTokenListing() event is logged with the following parameters
//     //   owner          the account that execute this transaction
//     //   symbol         symbol
//     //   name           name
//     //   decimals       number of decimal places for the token contract
//     //   initialSupply  the token initial supply
//     //   mintable       can tokens be minted after deployment?
//     //   transferable   are the tokens transferable after deployment?
//     // ------------------------------------------------------------------------
//     function deployBTTSTokenContract(
//         string symbol,
//         string name,
//         uint8 decimals,
//         uint initialSupply,
//         bool mintable,
//         bool transferable
//     ) public returns (address bttsTokenAddress) {
//         bttsTokenAddress = new BTTSTokenInterface(
//             msg.sender,
//             symbol,
//             name,
//             decimals,
//             initialSupply,
//             mintable,
//             transferable);
//         // Record that this factory created the trader
//         _verify[bttsTokenAddress] = true;
//         deployedTokens.push(bttsTokenAddress);
//         BTTSTokenListing(msg.sender, bttsTokenAddress, symbol, name, decimals, initialSupply, mintable, transferable);
//     }


//     // ------------------------------------------------------------------------
//     // Number of deployed tokens
//     // ------------------------------------------------------------------------
//     function numberOfDeployedTokens() public view returns (uint) {
//         return deployedTokens.length;
//     }

//     // ------------------------------------------------------------------------
//     // Factory owner can transfer out any accidentally sent ERC20 tokens
//     //
//     // Parameters:
//     //   tokenAddress  contract address of the token contract being withdrawn
//     //                 from
//     //   tokens        number of tokens
//     // ------------------------------------------------------------------------
//     function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
//         return ERC20Interface(tokenAddress).transfer(owner, tokens);
//     }

//     // ------------------------------------------------------------------------
//     // Don't accept ethers
//     // ------------------------------------------------------------------------
//     function () public payable {
//         revert();
//     }
// }