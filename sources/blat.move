// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module blat::BLAT {
    use std::ascii::string;
    use std::option;
    use sui::coin::{Self, TreasuryCap, Coin, CoinMetadata};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    const SYMBOL: vector<u8> = b"BLAT";
    const NAME: vector<u8> = b"BeLaunch Token";
    const TOTAL_SUPPLY: u64 = 100_000_000_000_000_000; // 100_000_000 * 10^9
    const DESCRIPTION: vector<u8> = b"The launchpad platform is safe and secure for everyone!";
    const DECIMAL: u8 = 9;
    const ICON_URL: vector<u8> = b"https://belaunch.s3.ap-southeast-1.amazonaws.com/media/images/blat.svg";

    /// Error codes
    const ERR_NOT_ADMIN: u64 = 0x10004;

    struct BLAT has drop {}

    /// initialize
    fun init(witness: BLAT, ctx: &mut TxContext) {
        is_admin_signer(ctx);
        let (treasury_cap, metadata) = create_and_mint(witness, TOTAL_SUPPLY, ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_share_object(treasury_cap);
    }

    /// must admin
    fun is_admin_signer(ctx: &mut TxContext) { 
        assert!(tx_context::sender(ctx) == @adblat, ERR_NOT_ADMIN); 
    }

    fun create_blat(
        witness: BLAT,
        ctx: &mut TxContext,
    ): (TreasuryCap<BLAT>, CoinMetadata<BLAT>) {
        coin::create_currency(
            witness, 
            DECIMAL, 
            SYMBOL, 
            NAME, 
            DESCRIPTION, 
            option::some(url::new_unsafe(string(ICON_URL))), 
            ctx
        )
    }

    fun create_and_mint(
        witness: BLAT,
        amount: u64,
        ctx: &mut TxContext,
    ): (TreasuryCap<BLAT>, CoinMetadata<BLAT>) {
        let (treasury_cap, metadata) = create_blat(witness, ctx);
        mint(&mut treasury_cap, amount, ctx);
        (treasury_cap, metadata)
    }

    public entry fun burn(
        treasury_cap: &mut TreasuryCap<BLAT>,
        coin: Coin<BLAT>,
        ctx: &mut TxContext
    ) {
        is_admin_signer(ctx);
        coin::burn(treasury_cap, coin);
    }

    public entry fun transfer(treasury_cap: TreasuryCap<BLAT>, recipient: address) {
        transfer::public_transfer(treasury_cap, recipient);
    }
    
    fun mint(treasury_cap: &mut TreasuryCap<BLAT>, amount: u64, ctx: &mut TxContext) {
        coin::mint_and_transfer(treasury_cap, amount, tx_context::sender(ctx), ctx)
    }



    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(BLAT {}, ctx);
    }
}