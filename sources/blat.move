// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module blat::BLAT {
    use std::ascii::string;
    use std::option;
    use sui::coin::{Self};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    const SYMBOL: vector<u8> = b"BLAT";
    const NAME: vector<u8> = b"BeLaunch Token";
    const TOTAL_SUPPLY: u64 = 100_000_000_000_000_000; // 100_000_000 * 10^9
    const DESCRIPTION: vector<u8> = b"The launchpad platform is safe and secure for everyone!";
    const DECIMAL: u8 = 9;
    const ICON_URL: vector<u8> = b"https://belaunchio.infura-ipfs.io/ipfs/Qme9yNdWnEVgJA4wMK3HeEm6UdvVpJa1gv2y5jLBJK8Jbe";

    struct BLAT has drop {}

    ///initialize
    fun init(witness: BLAT, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(
            witness, 
            DECIMAL, 
            SYMBOL, 
            NAME, 
            DESCRIPTION, 
            option::some(url::new_unsafe(string(ICON_URL))), 
            ctx
        );
        
        transfer::public_freeze_object(metadata);
        coin::mint_and_transfer(&mut treasury, TOTAL_SUPPLY, tx_context::sender(ctx), ctx);
        transfer::public_freeze_object(treasury);
    }


    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(BLAT {}, ctx);
    }
}