pragma solidity ^0.6.7;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "./BinaryOptionInterface.sol";

contract BinaryOptions is BinaryOptionInterface {
    //Overflow safe operators
    using SafeMath for uint;
    //Pricefeed interfaces
    AggregatorV3Interface internal Feed;
    uint Price;
    address payable contractAddr;
    
    //Options stored in arrays of structs
    struct option {
        uint strike; //Price in USD (18 decimal places) option allows buyer to purchase tokens at
        uint premium; //Fee in contract token that option writer charges
        uint expiry; //Unix timestamp of expiration time
        uint amount; //Amount of tokens the option contract is for
        uint id; //Unique ID of option, also array index
        address payable writer; //Issuer of option
        address payable buyer; //Buyer of option
        bool IsCall; //Call True | Put False
        bool exercised; //Has option been exercised
        bool canceled; //Has option been canceled
    }
    option[] public Opts;

    //Oracle feeds: https://docs.chain.link/docs/ethereum-addresses#mainnet
    constructor() public {
        // Kovan feed of ETH/USD, can put anyfeed 
        Feed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        contractAddr = payable(address(this));
    }

    function IsExercised(uint ID) external view virtual override returns (bool) {
        return Opts[ID].exercised;
    }
    
    function IsExpiried(uint ID) external view virtual override returns (bool) {
        return Opts[ID].exercised;
    }
    
    //Returns the latest price
    function getPrice() public view returns (uint) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = Feed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        //Price should never be negative thus cast int to unit is ok
        //Price is 8 decimal places and will require 1e10 correction later to 18 places
        return uint(price);
    }
    
    //Updates prices to latest
    function updatePrices() internal {
        Price = getPrice();
    }
    
    //Allows user to write a covered call option
    //Takes which token, a strike price(USD per token w/18 decimal places), premium(same unit as token), expiration time(unix) and how many tokens the contract is for
    function writeCall(uint strike, uint premium, uint expiry, uint tknAmt) public payable {
        require(msg.value == tknAmt, "Incorrect amount of ETH supplied"); 
        Opts.push(option(strike, premium, expiry, tknAmt, Opts.length, msg.sender, address(0), true, false, false));
    }
    
    function writePut(uint strike, uint premium, uint expiry, uint tknAmt) public payable {
        require(msg.value == tknAmt, "Incorrect amount of ETH supplied"); 
        Opts.push(option(strike, premium, expiry, tknAmt, Opts.length, msg.sender, address(0), false, false, false));
    }
    
    function updatePremium(uint ID, uint premium) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must not have already been canceled or bought
        require(!Opts[ID].canceled && Opts[ID].buyer == address(0), "This option cannot be updated");
        Opts[ID].premium = premium;
    }
    
    function updateStrike(uint ID, uint strike) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must not have already been canceled or bought
        require(!Opts[ID].canceled && Opts[ID].buyer == address(0), "This option cannot be updated");
       Opts[ID].strike = strike;
    }
    
    function updateExpiry(uint ID, uint expiry) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must not have already been canceled or bought
        require(!Opts[ID].canceled && Opts[ID].buyer == address(0), "This option cannot be updated");
       Opts[ID].expiry = expiry;
    }
    
    //Allows option writer to cancel and get their funds back from an unpurchased option
    function cancelOption(uint ID) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must not have already been canceled or bought
        require(!Opts[ID].canceled && Opts[ID].buyer == address(0), "This option cannot be canceled");
        Opts[ID].canceled = true;
        Opts[ID].writer.transfer(Opts[ID].amount);
        
    }
    
    //Purchase a call option, needs desired token, ID of option and payment
    function buyOption(uint ID) public payable {
        require(!Opts[ID].canceled && Opts[ID].expiry > now, "Option is canceled/expired and cannot be bought");
        //Transfer premium payment from buyer
        require(msg.value == Opts[ID].premium, "Incorrect amount of ETH sent for premium");
        //Transfer premium payment to writer
        Opts[ID].writer.transfer(Opts[ID].premium);
        Opts[ID].buyer = msg.sender;
        
    }
    
    //Exercise your call option, needs desired token, ID of option and payment
    function exercise(uint ID) public payable {
        //If not expired and not already exercised, allow option owner to exercise
        //To exercise, the strike value*amount equivalent paid to writer (from buyer) and amount of tokens in the contract paid to buyer
        require(Opts[ID].buyer == msg.sender, "You do not own this option");
        require(!Opts[ID].exercised, "Option has already been exercised");
        require(Opts[ID].expiry > now, "Option is expired");
        //Conditions are met, proceed to payouts
        updatePrices();
        if (Opts[ID].IsCall) {
            require(Price.mul(10**10) >= Opts[ID].strike, "Call option is Out of Money");
        } else {
            require(Price.mul(10**10) <= Opts[ID].strike, "Put option is Out of Money");
        }
        Opts[ID].exercised = true;
        msg.sender.transfer(Opts[ID].amount);
    }
    
    //Allows writer to retrieve funds from an unsold, non-exercised and non-canceled option
    function retrieveFunds(uint ID) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must be unsold, not exercised and not canceled
        require(Opts[ID].buyer == address(0) && !Opts[ID].exercised && !Opts[ID].canceled, "This option is not eligible for withdraw");
        //Repurposing canceled flag to prevent more than one withdraw
        Opts[ID].canceled = true;
        Opts[ID].writer.transfer(Opts[ID].amount);
        
        
    }
}
