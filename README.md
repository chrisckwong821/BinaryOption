# BinaryOption (AmericanOption)

A simplified variant of  ChainLink/ETH Option[https://github.com/gmondok/ChainlinkCallOptions/blob/main/chainlinkOptions.sol], this is a binary option contract that has predefined payout by a specific expiry date, support any pair(s) as long as an oracle exists, with premium and payout both in ETH.

Example:

**(CLASSIC)**

*Contract A:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 4 ETH

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 4 ETH -> 250% return.


**(Exotic)**

*Contract B:* Underlying : LINK, Strike : 15USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 2 ETH

It means that at any point in time before the expiry, if the price of LINK/USD in the Oracle is equal or greater than 15, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 2 ETH -> 500% return.

## Gas Cost

!(https://github.com/chrisckwong821@gmail.com/BinaryOption/blob/master/asset/gas.png?raw=true)
 
