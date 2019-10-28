# ETH Bank Pro
ETH Bank Pro is an open source, decentralized, fair investment smart contract.

## Key function definition

> The specific source code is in the Main.sol file.

| Function name    | Effect                            |
| ---------------- | --------------------------------- |
| invest           | User investment / re-investment   |
| _getInvestLevel  | Get user level                    |
| withdrawStatic   | Extract static rewards            |
| withdrawDynamic  | Extract dynamic rewards           |
| withdrawAmount   | Withdrawal of principal           |
| getInvestorCount | Get the total number of investors |

## Game rules

### 1. Membership system

| Cumulative investment(ETH) | VIP level |
| -------------------------- | --------- |
| 0.1 - 5.9                  | V1        |
| 6 - 10.9                   | V2        |
| 11 - 20                    | V3        |

### 2. Static revenue

**V1 Member:** Earn 0.5% of the principal per day

**V2 Member:** Earn 0.7% of the principal per day

**V3 Member:** Earn 1% of the principal per day

### 3. Invitation reward

**V1 Member:** Get 50% of the static benefits of the first generation under the umbrella every day.

**V2 Member:** Get 70% of the static benefits of the first generation and 50% of the second generation under the umbrella every day.

**V3 Member:** Get 100% of the static benefits of the first generation, 70% of the second generation, 50% of the third generation, 10% of the fourth to tenth generation, 5% of the 11th to 20th generation, and 1% of the 21st to the next unlimited generation under the umbrella every day.

### 4. Rule of withdrawal

1. A single account can invest 0.1 - 20 ETH. The income is calculated and distributed every day from 01:00 to 01:30 in Hong Kong time. The proceeds can be withdrawn at any time without any handling fee;

2. The principal freezing time is 5 days, and the cash can be withdrawn at any time after 5 days;

3. Burn rule: If the inviter's principal is less than the invitee's principal, the invitation bonus is calculated according to the inviter's principal, such as A investment 5 ETH, A invites B, B invests 20 ETH, then the invitation bonus that A received every day is 5 × 0.5% × 50% = 0.0125 ETH.
