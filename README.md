# BinaryOption (AmericanOption)

Improved upon https://github.com/gmondok/ChainlinkCallOptions/blob/main/chainlinkOptions.sol (ChainLink/ETH Option), this is a binary option contract that has predefined payout by a specific expiry date, support pairs as long as an oracle exist, premium in ETH/LINK, and any ERC20 as payout.

Example:

**(CLASSIC)**

*Contract A:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 4 ETH

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 10ETH. If he does, he gets 10 ETH with a bet of 4ETH -> 250% return.


**(Exotic)**

*Contract B:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 10 ETH, Premium: 100 LINK

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 100ETH. If he does, he gets 10 ETH with a bet of 100LINK.


**(Exotic)**

*Contract C:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 1000 LINK, Premium: 500 LINK

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 1000 LINK. If he does, he gets 1000 LINK with a bet of 500LINK -> 200% return 


**(Exotic)**

*Contract D:* Underlying : ETH, Strike : 600USD, Expiry (1609459199) - end of 2020, Amount : 1000 LINK, Premium: 1.5 ETH

It means that at any point in time before the expiry, if the price of ETH/USD in the Oracle is equal or greater than 600, the contract buyer is eligible to exercise the option and claim 1000 LINK. If he does, he gets 1000 LINK with a bet of 1.5 ETH
