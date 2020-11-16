pragma solidity ^0.6.7;

import "https://github.com/chrisckwong821/BinaryOption/blob/main/BinaryOptionInterface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract OptionOfOption {
    using SafeMath for uint;
    BinaryOptionInterface internal optionInterface;
    uint ID;
    address payable contractAddr;
    bool exercised_;
    bool expiried_;
    
    //Options stored in arrays of structs
    struct option {
        uint premium; //Fee in contract token that option writer charges
        uint expiry; //Unix timestamp of expiration time
        uint amount; //Amount of tokens the option contract is for
        uint id; //Unique ID of option, also array index
        address payable writer; //Issuer of option
        address payable buyer; //Buyer of option
        bool IsLong; // Long option can only be exercised when the underlying option is exercised; while a short option can only be exercised when underlying option is expired without being exercise
        bool exercised; //Has option been exercised
        bool canceled; //Has option been canceled
    }
    option[] public Opts;
    
    constructor() public {
        optionInterface = BinaryOptionInterface(0x0AbF726D454deb375f23cDb516f972DaF9b72C4e);
    }
    
    function updateStatus() internal {
        exercised_ = optionInterface.IsExercised(ID);
        expiried_ = optionInterface.IsExpiried(ID);
    }
    
    function writeLong(uint premium, uint expiry, uint tknAmt) public payable {
        require(msg.value == tknAmt, "Incorrect amount of ETH supplied"); 
        Opts.push(option(premium, expiry, tknAmt, Opts.length, msg.sender, address(0), true, false, false));
    }
    
    function writeShort(uint strike, uint premium, uint expiry, uint tknAmt) public payable {
        require(msg.value == tknAmt, "Incorrect amount of ETH supplied"); 
        Opts.push(option(premium, expiry, tknAmt, Opts.length, msg.sender, address(0), false, false, false));
    }
    
    function updatePremium(uint ID, uint premium) public payable {
        require(msg.sender == Opts[ID].writer, "You did not write this option");
        //Must not have already been canceled or bought
        require(!Opts[ID].canceled && Opts[ID].buyer == address(0), "This option cannot be updated");
        Opts[ID].premium = premium;
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
        updateStatus();
        if (Opts[ID].IsLong) {
            require(optionInterface.IsExercised(ID), "Long option with underlying not exercised");
        } else {
            require(optionInterface.IsExpiried(ID) && !optionInterface.IsExercised(ID), "Short option with underlying not expired unexercised");
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
