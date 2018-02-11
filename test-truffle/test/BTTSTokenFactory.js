var BTTSTokenFactory = artifacts.require("../contracts/BTTSTokenFactory.sol");
var BTTSLib = artifacts.require("../contracts/BTTSLib.sol");


//test accounts
//0: 0x6F59B10F96c027faf0fE92fD45f95855A763c8eb //owner
//1: 0x34f06373E492e6Ba87cBCb655ccc1d0951F734D3 //fund
//2: 0x7A8f86C5C3CA815E182188567CC44ca9738549AF //devops
//3: 0xdc97e6821eC70f437790a38cD116F47a670Ae4b8 //token buyer (tokenBuyerAccount)
//4: 0xb0fEA9E63b32Ce717f7A0283650863630d4F5Eb6 //tokenBuyerAccount2


//tests:
// "Mint Tokens"
// "Start Transfers"
// "Unlock Accounts"
// BTTS support functions
// "Signed Transfers"
// "Signed Approve"
//  "Signed TransferFrom"
// "Transfer Tokens"
// "Move 0 Tokens After Transfers Allowed"
// "Move More Tokens Than Owned"
// "Change Approval Without Setting To 0"

contract('BTTSTokenFactory', function(accounts) {
    var instanceToken;
    var instanceTokenFactory;
    var logErrorEvents;
    
    var contractOwnerAccount = accounts[0];
    
    // var tokenAddressVar;
    // var logTokenPurchase;
    //var logErrorEventsaccountfour;
    // var logTokenPurchaseaccountfour;
    var account_one = accounts[0];
    var account_two = accounts[1];
    var account_three = accounts[2];
    // var account_four = accounts[3];


    var runTest_1 = true;
    var runTest_2 = true;
    var runTest_3 = true;
    var runTest_4 = true;
    var runTest_5 = true;
    

    // Utility function to display the balances of each account.
    function printBalances(accounts) {
        console.log("printBalances:");
        for(i = 0; i < 5; i++) {
            console.log(i, web3.fromWei(web3.eth.getBalance(accounts[i]), 'ether').toNumber());
        }
    }

    function printTokenBalances() {
            console.log("printTokenBalances:");
        
            return instanceToken.balanceOf(account_one)
            .then(function(balance) {
              console.log("account_one/contractOwnerAccount.tokenbalance: " + balance);
                              
              return instanceToken.balanceOf(account_two);
            })
            .then(function(balance) {
              console.log("account_two.tokenbalance: " + balance);
            })
            .then(function() {
              return instanceToken.balanceOf(account_three);
            })
            .then(function(balance) {
              console.log("account_three.tokenbalance: " + balance);
            })
            ;        
      }
  
    
    
    //utility function to show logs
    function logTransactionEvents() {
          logErrorEvents = instanceToken.LogErr({_sender: account_one}, {fromBlock: 0, toBlock: 'latest'});
          logErrorEvents.watch(function(err, result) {
            if (err) {
              console.log("instanceToken ERROR in LogErr Event! account one");
              console.log(err);
              return;
            }
            // append details of result.args to UI
          });
  
        //   logTokenPurchase = instanceICO.LogTokenPurchase({_sender: account_one}, {fromBlock: 0, toBlock: 'latest'});
        //   logTokenPurchase.watch(function(err, result) {
        //     if (err) {
        //       console.log("instanceICO ERROR in LogTokenPurchase Event! account one");
        //       console.log(err);
        //       return;
        //     }
        //     if (result) {
        //       console.log(result)
        //       return;
        //     }
        //     // append details of result.args to UI
        //   });
  
        //   logErrorEventsaccountfour = instanceToken.LogErr({_sender: account_four}, {fromBlock: 0, toBlock: 'latest'});
        //   logErrorEventsaccountfour.watch(function(err, result) {
        //     if (err) {
        //       console.log("instanceToken ERROR in LogErr Event! account four");           
        //       console.log(err);
        //       return;
        //     }
        //     // append details of result.args to UI
        //   });
          
        //   logTokenPurchaseaccountfour = instanceICO.LogTokenPurchase({_sender: account_four}, {fromBlock: 0, toBlock: 'latest'});
        //   logTokenPurchaseaccountfour.watch(function(err, result) {
        //     if (err) {
        //       console.log("instanceICO ERROR in LogTokenPurchase Event! account four");                       
        //       console.log(err);
        //       return;
        //     }
        //     if (result) {
        //       console.log(result);
        //       return;
        //     }
        //     // append details of result.args to UI
        //   });
  
    }

    beforeEach(function (done) {
        setTimeout(function(){
          done();
        }, 1000);

        
        console.log("****** ***** ***** ***** ****** ");
        console.log("******  ****** ");
        console.log("****** ***** ***** ***** ****** ");
      });


    before(function() {
        // runs before each test in this block
        return BTTSTokenFactory.deployed()
        .then(function(_instanceTokenFactory) {
            instanceTokenFactory = _instanceTokenFactory;
            console.log("BTTSTokenFactory.address: " + instanceTokenFactory.address);
            // symbol,  name, decimals, initialSupply, mintable, transferable
            return instanceTokenFactory.deployBTTSTokenContract("SHIP", "ShipChain Token", 18, 500000000, true, true);
        })
        .then(function(_bttsTokenAddress) {            
            console.log("_bttsTokenAddress: " + _bttsTokenAddress);

            return BTTSToken(_bttsTokenAddress);
        })
        .then(function(_instanceToken) {            
            console.log("_instanceToken: " + _instanceToken);
            
            printBalances(accounts);
            printTokenBalances();      
        });
      
    });
  
    it("1: owner should mint tokens - mintTokens", function() {
        
        console.log("1: owner should mint tokens - mintTokens");
        if(!runTest_1)
        {
            console.log("1: test disabled");
            done();
            
            return;  
        }
  

        // console.log("RESULT: --- " + mintTokensMessage + " ---");
        // var mintTokens1Tx = token.mint(account3, "1000000000000000000000000", true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
        // var mintTokens2Tx = token.mint(account4, "1000000000000000000000000", true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
        // while (txpool.status.pending > 0) {
        // }
        // printBalances();
        // failIfTxStatusError(mintTokens1Tx, mintTokensMessage + " - mint 1,000,000 tokens 0x0 -> ac3");
        // failIfTxStatusError(mintTokens2Tx, mintTokensMessage + " - mint 1,000,000 tokens 0x0 -> ac4");
        // printTxData("mintTokens1Tx", mintTokens1Tx);
        // printTxData("mintTokens2Tx", mintTokens2Tx);
        // printTokenContractDetails();
        // console.log("RESULT: ");



        return instanceToken.totalSupply()
        .then(function(_totalSupply) {
            console.log("_totalSupply: " + _totalSupply);
            
            return instanceToken.mint(account_two, "1000000000000000000000000", true, { from: contractOwnerAccount, gas: 400000 });
        })
        
        .then(function(tx) {
            assert.isOk(tx);
            console.log("1: Transaction is ok ");
            
            return printTokenBalances();

        })
        .catch(function(e) {
            console.log("Transaction failed!");
            console.log(e);
    
        })
        .then(function() {
            return instanceToken.totalSupply();
        })
        .then(function(_totalSupply) {
            console.log("_totalSupply: " + _totalSupply);
        })
        .then(function() {
            return instanceToken.balanceOf(account_two);
        })
        .then(function(_newBalance) {
            console.log("_newBalance: " + _newBalance);


            //.equal(actual, expected, [message])
            assert.equal(_newBalance, "1000000000000000000000000", "Error wrong amount in account_two token balance ");
        })
        ;
        
    });
  
  
    // it("2: Send Tokens - from tokenBuyerAccount to tokenBuyerAccount2 ", function() {
    //     if(!runTest_2)
    //     {
    //       console.log("2: test disabled");
    //       done();
          
    //       return;  
    //     }
        
    //   logTransactionEvents();
  
    //   console.log("2: Send 2150 Tokens - from account_two to account_three ");
  
    //   var TokenAccount_sendFrom_account_two = account_two;
    //   var TokenAccount_sendTo_account_three = account_three;
    //   var tokenAmounttoTransfer = 13; 
  
        
    //     //get tokenBuyerAccount token balance before transfer
    //     return instanceToken.balanceOf(TokenAccount_sendFrom_account_two)
    //     .then(function(balance) {     
    //         console.log("TokenAccount_sendFrom.tokenbalance-before: " + balance);
    //         return;
    //     })
  

    //     //get TokenAccount_sendTo token balance before transfer
    //     .then(function() {     
    //         return instanceToken.balanceOf(TokenAccount_sendTo_account_three);
    //     })
    //     .then(function(balance) {     
    //         console.log("TokenAccount_sendTo.tokenbalance-before: " + balance);
    //         return;
    //     })
    

    //     //print ether values before 
    //     .then(function() {
    //         ////get owner.etherbalance_before
    //         //console.log("owner.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(tokenContract_OwnerAddress), 'ether').toNumber());
            
    //         //get TokenAccount_sendFrom.etherbalance
    //         console.log("TokenAccount_sendFrom.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(TokenAccount_sendFrom_account_two), 'ether').toNumber());
            
    //         //get TokenAccount_sendTo.etherbalance-before
    //         console.log("TokenAccount_sendTo.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(TokenAccount_sendTo_account_three), 'ether').toNumber());
    
    //         return;
    //     })
  

    //     //Send tokens from TokenAccount_sendFrom to TokenAccount_sendTo
    //     .then(function() {
    //         return instanceToken.transfer(TokenAccount_sendTo_account_three, tokenAmounttoTransfer, {from: TokenAccount_sendFrom_account_two, gas: 4000000 });
    //     })
    //     .then(function(tx) {
    //         assert.isOk(tx);
    

            
    //         return;
    //     })
    //     .catch(function(e) {
    //         // There was an error! Handle it.  
    //         console.log("Transaction failed!");
    //         console.log(e);
    //     })
  

    //     //get TokenAccount_sendFrom token balance after transfer
    //     .then(function() {     
    //         return instanceToken.balanceOf(TokenAccount_sendFrom_account_two);
    //     })
    //     .then(function(balance) {     
    //         console.log("TokenAccount_sendFrom.tokenbalance-after: " + balance);
    //         return;
    //     })
  

    //     //get tokenBuyerAccount2 token balance after transfer
    //     .then(function() {     
    //         return instanceToken.balanceOf(TokenAccount_sendTo_account_three);
    //     })
    //     .then(function(balance) {     
    //         console.log("TokenAccount_sendTo.tokenbalance-after: " + balance);

    //         //.equal(actual, expected, [message])
    //         assert.equal(balance, 13, "Error wrong amount in account_two token balance ");

    //         return;
    //     })
    //     ;
  
    // });
  
    // //- Anyone: create new Load contract entry
    // it("3: it should create new shipment - Load v2", function(done) {
    //     console.log("*** TEST: contract should create new shipment - Load v2 - started");
        
    //     //this.timeout(2000);
        
    //     if(!runTest_3)
    //     {
    //         console.log("runTest_3: " + runTest_3);
    //         console.log("TEST EXCUTION SKIPPED");
    //         done();
    //         return;
    //     }

    //     var shipperAccount = accounts[0];
    //     var carrierAccount = accounts[1];
    //     console.log("shipperAccount.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(shipperAccount), 'ether').toNumber());
    //     console.log("carrierAccount.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(carrierAccount), 'ether').toNumber());
        
    //     //Contract
    //     var load = null;//contract object
    //     var shipmentID = 0;//placeholder for the shipment id returned from the contract

    //     //input data
    //     //var payloadURL = "12345";
    //     //var waypointsURL = "67890";
    //     var validUntilHours  = 24;
    //     //var shipmentETHAmount  = iGlobalShipmentAmount;
    //     //var shipmentETHAmount = web3.toWei(1, "ether"); //web3.fromWei(2000000000000, 'ether').toNumber();
    //     var shipmentETHAmount = web3.toWei(iGlobalShipmentAmount, "ether");

    //     Load.deployed()
    //     .then(function(_load) {
    //         load = _load
    //         return load.createNewShipment(shipperAccount, carrierAccount, validUntilHours, shipmentETHAmount, { from: shipperAccount, gas: 500000});
    //      })
    //     .then(function(tx) {
    //         //shipmentID returned?
    //         console.log("shipchain.createNewShipment.then(function(tx) entered:");
    //         console.log("tx.receipt" + tx.receipt);

    //         assert.isOk(tx.receipt)
            
    //         console.log("Transaction successful!");
        
    //         console.log("shipperAccount.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(shipperAccount), 'ether').toNumber());
    //         console.log("carrierAccount.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(carrierAccount), 'ether').toNumber());
            
    //     })
    //     .catch(function(e) {
    //         // There was an error! Handle it.  
    //         console.log("Transaction failed!");
    //         console.log(e);

    //     })
    //     // .then(function() { 
    //     //     console.log("getLatestShipmentIDFromAny  call...");            
    //     //     return load.getLatestShipmentIDFromAny.call(); //{ from: shipperAccount, gas: 400000});

    //     //     //return load.getLatestShipmentIDFromShipper.call(shipperAccount); //{ from: shipperAccount, gas: 400000});
            
    //     // })
    //     // .then(function(_latestShipmentIDFromAny) {
    //     //     globalLatestShipmentID = _latestShipmentIDFromAny;
    //     //     console.log("_latestShipmentIDFromAny:" + _latestShipmentIDFromAny);            
            
    //     //     //return load.getLatestShipmentIDFromShipper.call(shipper); //{ from: shipperAccount, gas: 400000});
            
    //     // })
    //     // // .then(function(_latestShipmentIDFromShipper) {
    //     // //     globalLatestShipmentID = _latestShipmentIDFromShipper;
    //     // //     console.log("latestShipmentIDFromShipper:" + _latestShipmentIDFromShipper);            
    //     // //     console.log("globalLatestShipmentID:" + globalLatestShipmentID);            
            
    //     // // })
    //     .then(function() {
    //         return load.createNewShipment(shipperAccount, carrierAccount, validUntilHours, shipmentETHAmount, { from: shipperAccount, gas: 500000});
    //     })
    //     .then(function(tx) {
    //         //shipmentID returned?
    //         console.log("shipchain.createNewShipment.then(function(tx) entered:");
    //         console.log("tx.receipt" + tx.receipt);

    //         assert.isOk(tx.receipt)
            
    //         console.log("Transaction successful!");
        
    //         console.log("shipperAccount.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(shipperAccount), 'ether').toNumber());
    //         console.log("carrierAccount.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(carrierAccount), 'ether').toNumber());
            
    //     })
    //     .catch(function(e) {
    //         // There was an error! Handle it.  
    //         console.log("Transaction failed!");
    //         console.log(e);

    //     })
    //     .then(function() {

    //         globalLatestShipmentID = 2;//hardcoded to fix truffle bug?
    //     })
    //     // .then(function() { 
    //     //     console.log("getLatestShipmentIDFromAny  call...");            
    //     //     return load.getLatestShipmentIDFromAny.call(); //{ from: shipperAccount, gas: 400000});

    //     //     //return load.getLatestShipmentIDFromShipper.call(shipperAccount); //{ from: shipperAccount, gas: 400000});
            
    //     // })
    //     // .then(function(_latestShipmentIDFromAny) {
    //     //     globalLatestShipmentID = _latestShipmentIDFromAny;
    //     //     console.log("_latestShipmentIDFromAny:" + _latestShipmentIDFromAny);            
            
    //     //     //return load.getLatestShipmentIDFromShipper.call(shipper); //{ from: shipperAccount, gas: 400000});
            
    //     // })
    //     .then(() => {done()})
    //     .catch(done)
    //     ;

    // });

    // // - Shipper/Carrier only: get Load contract details
    // it("4: it should find new stored getShipmentContractDetails ", function(done) {
    //     console.log("*** TEST: hould find new stored getShipmentContractDetails - started");
    //     //this.timeout(4000);
        
    //     //#region configure test execution
    //     if(!runTest_4)
    //     {
    //         console.log("runTest_4: " + runTest_4);
    //         console.log("TEST EXCUTION SKIPPED");
    //         done();
    //         return;
    //     }
    //     //#endregion

    //     var load = null;//contract object

    //     Load.deployed()
    //     .then(function(_load) {
    //         load = _load;
    //         console.log("globalLatestShipmentID:" + globalLatestShipmentID);            
    //         console.log("call: getShipmentContractDetails:");            
            
    //         return load.getShipmentContractDetails.call(globalLatestShipmentID);
    //     })
    //     .then(function(result) {
    //         console.log("result[0]-shipmentID: " + result[0]);
    //         console.log("result[1]-shipper: " + result[1]);
    //         console.log("result[2]-carrier: " + result[2]);
    //         console.log("result[3]-escrowStatusID: " + result[3]);
    //         console.log("result[4]-shipmentStatusID: " + result[4]);


    //         assert.isNotNull(result[0], "shipment id expected to be a value, but it wasnt");
            

    //     })        
    //     .then(() => {done()})
    //     .catch(function(e) {
    //         // There was an error! Handle it.  
    //         console.log("Transaction failed!");
    //         console.log(e);
    //         done();
    //     })
    //     //.catch(done)
    //     ;


    // });


    // it("5: Pay SHIP tokens to the Load contract - via the token contract - transferAndCall", function() {


    //   if(!runTest_5)
    //   {
    //     console.log("runTest_5:test disabled");
    //     done();
        
    //     return;  
    //   }
    //   logTransactionEvents();
  
    //   console.log("5: Pay SHIP tokens to the Load contract - via the token contract - transferAndCall");
    //   //prepoare by creating a shipment ID 1
    //   //call token contract
    //   //function: SHPToken.transferAndCall
    //   // - transfer tokens from msg.sender to the Load contract 
    //   // - call tokenFallback function on the Load contract
    //   //function: Load.tokenFallback
    //   // - increase paidTokens total for the shipment id
    //   // - if paid tokens are equak or above a level (10 now), then set isEscrowFundedWithTokens for the shipment id
  
    //   //var tokenContract_OwnerAddress;//contract address of the generated token
    //   //var the_owner = account_one;
    //   var shipperAccount = account_two;
    //   var instanceLoadContract_address; //receiver of tokens = instanceLoad.address;
    //   //var TokenAccount_founder1_tokenAmountToReceive;
    //   //var TokenAccount_founder2_tokenAmountToReceive;
  
    //   //var instanceLoadContract_address;
  
    //     //get owneraddress of token
    //     return instanceLoad.getShipmentContractDetails.call(1)
    //     .then(function(details) {
    //         instanceLoadContract_address = instanceLoad.address;

    //         console.log("details[0]-shipmentID: " + details[0]);
    //         console.log("details[1]-shipper: " + details[1]);
    //         console.log("details[2]-carrier: " + details[2]);
    //         console.log("details[3]-escrowStatusID: " + details[3]);
    //         console.log("details[4]-shipmentStatusID: " + details[4]);
    //         console.log("details[4]-ShipmentAmount: " + details[5]);
    //         console.log("details[4]-PaidAmount: " + details[6]);

    //         //assert.isNotNull(details[0], "shipment id expected to be a value, but it wasnt");
            
    //         return;
    //     })   
    //     .then(function() {   
    //         return instanceLoad.getShipmentContractDetailsExtended.call(1);
    //     })
    //     .then(function(details) {     
    //         console.log("details[0]-shipmentID: " + details[0]);
    //         console.log("details[1]-paidTokens: " + details[1]);
    //         return;
    //     })
        

    //   //get TokenAccount_founder1 token balance before payout
    //   .then(function() {   
    //     return instanceToken.balanceOf(shipperAccount);
    //   })
    //   .then(function(balance) {     
    //     console.log("shipperAccount.tokenbalance: " + balance);
    //     return;
    //   })
    //   //get TokenAccount_founder2 token balance before transfer
    //   .then(function() {     
    //     return instanceToken.balanceOf(instanceLoadContract_address);
    //   })
    //   .then(function(balance) {     
    //     console.log("instanceLoadContract_address.tokenbalance: " + balance);
    //     return;
    //   })



    //   //print ether values before 
    //   .then(function() {
        
    //     //get TokenAccount_founder1.etherbalance
    //     console.log("shipperAccount.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(shipperAccount), 'ether').toNumber());
        
    //     //get instanceLoadContract_address 
    //     console.log("TokenAccount_founder2.etherbalance-before: " + web3.fromWei(web3.eth.getBalance(instanceLoadContract_address), 'ether').toNumber());
  
    //     return;
    //   })



    //   .then(function() {     
    //     console.log("SHPToken.transferAndCall..");
    //     return instanceToken.transferAndCall(instanceLoadContract_address, 10, 1, {from: shipperAccount, gas: 4000000 });
    //   })
    //   .then(function(tx) {
    //     //shipmentID returned?
    //     console.log("SHPToken.transferAndCall.then(function(tx) entered:");
    //     console.log("tx.receipt" + tx.receipt);

    //     assert.isOk(tx.receipt)
        
    //     console.log("Transaction successful!");
    
    //     console.log("shipperAccount.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(shipperAccount), 'ether').toNumber());
    //     console.log("instanceLoadContract_address.etherbalance-after: " + web3.fromWei(web3.eth.getBalance(instanceLoadContract_address), 'ether').toNumber());
        
    //     })
    //     .catch(function(e) {
    //         // There was an error! Handle it.  
    //         console.log("Transaction failed!");
    //         console.log(e);

    //     })



    //     .then(function() {     
    //         console.log("get shipment details ..");
    //         console.log("..... ..... .....");
    //         return instanceLoad.getShipmentContractDetails.call(1);
            
    //     })
    //     .then(function(details) {
    //         console.log("details[0]-shipmentID: " + details[0]);
    //         console.log("details[1]-shipper: " + details[1]);
    //         console.log("details[2]-carrier: " + details[2]);
    //         console.log("details[3]-escrowStatusID: " + details[3]);
    //         console.log("details[4]-shipmentStatusID: " + details[4]);
    //         console.log("details[4]-ShipmentAmount: " + details[5]);
    //         console.log("details[4]-PaidAmount: " + details[6]);
            

    //         //assert.isNotNull(details[0], "shipment id expected to be a value, but it wasnt");
            
    //         return;
    //     })
    //     .then(function() {   
    //         return instanceLoad.getShipmentContractDetailsExtended.call(1);
    //     })
    //     .then(function(details) {     
    //         console.log("details[0]-shipmentID: " + details[0]);
    //         console.log("details[1]-paidTokens: " + details[1]);
    //         return;
    //     })
      
      
    //     //get  token balance after payout
    //     .then(function() {   
    //         return instanceToken.balanceOf(shipperAccount);
    //     })
    //     .then(function(balance) {     
    //         console.log("shipperAccount.tokenbalance: " + balance);
    //         return;
    //     })
    //     //get token balance after transfer
    //     .then(function() {     
    //         return instanceToken.balanceOf(instanceLoadContract_address);
    //     })
    //     .then(function(balance) {     
    //         console.log("instanceLoadContract_address.tokenbalance: " + balance);
    //         return;
    //     })
    //     ;

    // });
});
