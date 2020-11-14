# BinaryOption

Improved upon https://github.com/gmondok/ChainlinkCallOptions/blob/main/chainlinkOptions.sol (ChainLink/ETH Option), this is a binary option contract that has predefined payout and premium by a specific expiry date.

Example:
Contract A: ETH strike : 600USD, expiry (1609459199) - end of 2020, amount : 10ETH 
Writer: 4 ETH

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 4ETH -> 250% return.
