# Retail Loyalty Points System

A blockchain-based loyalty points system that allows retailers to:

- Award points to customers for purchases
- Let customers redeem points for rewards
- Enable points transfer between customers
- Manage authorized retailers
- Configure tiered rewards with points multipliers

## Features

- Mint loyalty points as fungible tokens
- Authorize/manage participating retailers
- Award points to customer wallets
- Redeem points through burning mechanism
- Transfer points between customers
- View points balances and authorized retailers
- Reward tiers with configurable multipliers
- Automatic tier-based point multipliers

## Contract Functions

- award-points: Allows authorized retailers to give points to customers
- redeem-points: Lets customers burn points for rewards
- transfer-points: Enables points transfer between customers
- add-retailer: Adds new authorized retailers
- get-points-balance: Checks points balance for any address
- get-authorized-retailers: Lists all participating retailers
- set-reward-tier: Configure reward tier parameters
- get-customer-tier: Get current tier for a customer
- get-tier-info: View reward tier details

## Reward Tiers

The system supports configurable reward tiers that provide point multipliers based on customer loyalty level. Higher tiers give better earning rates for points.

Example tiers:
- Bronze: 1x multiplier (default)
- Silver: 2x multiplier (1000+ points)
- Gold: 3x multiplier (5000+ points)
- Platinum: 4x multiplier (10000+ points)

Built with Clarity for the Stacks blockchain.
