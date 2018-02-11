
//var BTTSTokenFactory = artifacts.require("../../contracts/BTTSTokenFactory.sol");
var BTTSToken = artifacts.require("../contracts/BTTSToken.sol");
var BTTSTokenFactory = artifacts.require("../contracts/BTTSTokenFactory.sol");
var BTTSLib = artifacts.require("../contracts/BTTSLib.sol");
var Owned = artifacts.require("../contracts/Owned.sol");


module.exports = function(deployer) {
    console.log("deploy started");
    var account_one = "0x6f59b10f96c027faf0fe92fd45f95855a763c8eb";

    console.log("account_one: ", account_one);

    deployer.deploy(Owned, { from: account_one, gas: 24000000 } )
    .then(function(){

        console.log("Owned deployed at: ", Owned.address);

        return deployer.link(Owned, BTTSTokenFactory);
        
    })
    .then(function(){
        console.log("Owned linked to BTTSTokenFactory");
        
        return deployer.deploy(BTTSLib, { from: account_one, gas: 24000000 } );
    })
    .then(function(){

        console.log("BTTSLib deployed at: ", BTTSLib.address);

        return deployer.link(BTTSLib, BTTSToken);
    })
    .then(function(){
        console.log("BTTSLib linked to BTTSToken");
        
        return deployer.deploy(BTTSToken, { from: account_one, gas: 24000000 } );
    })
    .then(function(){
        console.log("BTTSToken deployed at: ", BTTSToken.address);
        return;
        //return deployer.deploy(BTTSToken, { from: account_one, gas: 24000000 } );
    })

    .then(function(){
        
        
        console.log("deploy started -  BTTSTokenFactory");
        return deployer.deploy(BTTSTokenFactory, { from: account_one, gas: 24000000 });


    })
    .then(function(){
        console.log("BTTSTokenFactory deployed at: ", BTTSTokenFactory.address);

        return;
    })
    ;

    

  
};



