
var Owned = artifacts.require("../contracts/Owned.sol");
var ApproveAndCallFallBack = artifacts.require("../contracts/ApproveAndCallFallBack.sol");
var BTTSLib = artifacts.require("../contracts/BTTSLib.sol");
var BTTSToken = artifacts.require("../contracts/BTTSToken.sol");
var BTTSTokenFactory = artifacts.require("../contracts/BTTSTokenFactory.sol");

//var allContracts = artifacts.require("../contracts/BTTSTokenFactory.sol");
//var BTTSLib = allContracts.BTTSLib;

module.exports = function(deployer) {
    console.log("deploy started");
    var account_one = "0x6f59b10f96c027faf0fe92fd45f95855a763c8eb";
    //var account_one = "0x3cce38471635b96341c17b07d59f8abdfbde1118";

    console.log("account_one: ", account_one);

    deployer.deploy(Owned, { from: account_one, gas: 4500000 } )
    .then(function(){

        console.log("Owned deployed at: ", Owned.address);

        return deployer.deploy(BTTSLib);
        
    })
    .then(function(){
        console.log("BTTSLib deployed at: ", BTTSLib.address);

        return deployer.link(BTTSLib, BTTSToken);

    })
    .then(function(){
        console.log("BTTSLib linked to BTTSToken");

        return deployer.deploy(BTTSToken, { from: account_one, gas: 4500000 } );
        
    })
    .then(function(){
        console.log("BTTSToken deployed at: ", BTTSToken.address);
        
        //return deployer.deploy(BTTSToken, { from: account_one, gas: 4500000 } );
    })
    .then(function(){
        //console.log("BTTSToken deployed at: ", BTTSToken.address);
        return;
    })

    .then(function(){
        
        
        //console.log("deploy started -  BTTSTokenFactory");
        //return deployer.deploy(BTTSTokenFactory, { from: account_one, gas: 4700000 });


    })
    .then(function(){
        //console.log("BTTSTokenFactory deployed at: ", BTTSTokenFactory.address);

        return;
    })
    ;

    

  
};



