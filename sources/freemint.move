module freemint::nft {
    use std::string::{Self, utf8, String};
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event::emit;
    use sui::package;
    use sui::display;

    /// One-Time-Witness for the module.
    struct NFT has drop {}

    struct NewNFT has copy, drop {
        minter: address,
        id: ID,
    }

    struct NFTObject has key, store {
        id: UID,
        name: String,
        image_url: String,
    }

    fun init(otw: NFT, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
        ];
        let values = vector[
            utf8(b"{name}"),
            utf8(b"{image_url}"),
        ];
        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<NFTObject>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public entry fun mint(name: vector<u8>, image_url: vector<u8>, ctx: &mut TxContext) {
        let sender: address = tx_context::sender(ctx);
        let nft = NFTObject {
            id: object::new(ctx),
            name: string::utf8(name),
            image_url: string::utf8(image_url),
        };
        emit(NewNFT {
            minter: sender,
            id: object::id(&nft),
        });
        transfer::public_transfer(nft, sender);
    }

}