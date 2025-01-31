import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test retailer authorization",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const retailer = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('loyalty-points', 'add-retailer', 
                [types.principal(retailer.address)], 
                deployer.address
            )
        ]);
        
        block.receipts[0].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Test points award and redemption",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const retailer = accounts.get('wallet_1')!;
        const customer = accounts.get('wallet_2')!;
        
        // Add retailer first
        chain.mineBlock([
            Tx.contractCall('loyalty-points', 'add-retailer',
                [types.principal(retailer.address)],
                deployer.address
            )
        ]);
        
        let block = chain.mineBlock([
            // Award points
            Tx.contractCall('loyalty-points', 'award-points',
                [types.principal(customer.address), types.uint(100)],
                retailer.address
            ),
            // Check balance
            Tx.contractCall('loyalty-points', 'get-points-balance',
                [types.principal(customer.address)],
                customer.address
            ),
            // Redeem points
            Tx.contractCall('loyalty-points', 'redeem-points',
                [types.uint(50)],
                customer.address
            )
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectOk().expectUint(100);
        block.receipts[2].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Test reward tiers and multipliers",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const retailer = accounts.get('wallet_1')!;
        const customer = accounts.get('wallet_2')!;

        // Setup reward tiers
        let block = chain.mineBlock([
            Tx.contractCall('loyalty-points', 'set-reward-tier',
                [types.uint(1), types.ascii("Silver"), types.uint(1000), types.uint(2)],
                deployer.address
            ),
            Tx.contractCall('loyalty-points', 'add-retailer',
                [types.principal(retailer.address)],
                deployer.address
            ),
            // Award initial points to reach Silver tier
            Tx.contractCall('loyalty-points', 'award-points',
                [types.principal(customer.address), types.uint(1000)],
                retailer.address
            ),
            // Award more points with multiplier
            Tx.contractCall('loyalty-points', 'award-points',
                [types.principal(customer.address), types.uint(100)],
                retailer.address
            )
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
        block.receipts[1].result.expectOk().expectBool(true);
        block.receipts[2].result.expectOk();
        block.receipts[3].result.expectOk();

        // Check final balance reflects multiplier
        let balanceBlock = chain.mineBlock([
            Tx.contractCall('loyalty-points', 'get-points-balance',
                [types.principal(customer.address)],
                customer.address
            )
        ]);

        // Should be 1000 + (100 * 2) = 1200
        balanceBlock.receipts[0].result.expectOk().expectUint(1200);
    }
});
