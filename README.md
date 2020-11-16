# BinaryOption (AmericanOption)

A simplified variant of  [ChainLink/ETH Option](https://github.com/gmondok/ChainlinkCallOptions/blob/main/chainlinkOptions.sol), this is a binary option contract that has predefined payout by a specific expiry date, support any pair(s) as long as an oracle exists, with premium and payout both in ETH.

Example:

Classic
-------

*Contract A:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 4 ETH

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 4 ETH -> 250% return.


Exotic
------

*Contract B:* Underlying : LINK, Strike : 15USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 2 ETH

It means that at any point in time before the expiry, if the price of LINK/USD in the Oracle is equal or greater than 15, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 2 ETH -> 500% return.

Benefit of BinaryOption
-----------------------

Given a predefined payout structure, Binary Option has a specific risk reward ratio as soon as the fixed amount of premium is paid. This makes trading and option exercise more intuitive and friendly to the end-user. With a cost-effective interface, premium/strike can also be adjusted on-chain with minimal cost.

## Gas Cost

![alt text](https://github.com/chrisckwong821/BinaryOption/blob/main/asset/gas.png?raw=true)
 
Enhancement
----------
Given a binary option is purchased, OptionOverOption(OOO) can be offered to further shift some of the risk of the underlying binary options, by issuing:

*LONG OOO* : which pays out only when underlying Binary Option expires EXERCISED(expired In-the-money)

*SHORT OOO* : which pays out only when underlying Binary Option expires UNEXERCISED (expired Out-of-the-money)

Noted that the OOO issuer can be anyone other than the buyer of the underlying binary option. However you would not be able to exercise the underlying Binary Option even when it is In-the-money if you issue OOO without being the buyer of its underlying. 

While any rational participants would exercise the option to collect payout whenever possible, they may be incentizived to keep the contract unexercised if they take an even larger position of second-order derivative (eg: this type of OOO), betting on the SHORT side of the Binary Option.
