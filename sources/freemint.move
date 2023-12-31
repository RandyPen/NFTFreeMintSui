module freemint::nft {
    use std::string::{Self, utf8, String};
    use sui::object::{Self, UID, ID};
    use std::option::{Self, Option};
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
        recipient: address,
    }

    struct BurnNFT has copy, drop {
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

    public entry fun mint(name: vector<u8>, image_url: vector<u8>, recipient: Option<address>, ctx: &mut TxContext) {
        let sender: address = tx_context::sender(ctx);

        let recipient = if (option::is_some(&recipient)) {
            let rec = option::destroy_some(recipient);
            rec
        } else {
            sender
        };

        let nft = new_nft(name, image_url, ctx);

        emit(NewNFT {
            minter: sender,
            id: object::id(&nft),
            recipient,
        });
        transfer::public_transfer(nft, recipient);
    }

    public fun new_nft(name: vector<u8>, image_url: vector<u8>, ctx: &mut TxContext): NFTObject {
        NFTObject {
            id: object::new(ctx),
            name: string::utf8(name),
            image_url: string::utf8(image_url),
        }
    }

    public entry fun burn(nft: NFTObject) {
        emit(BurnNFT {
            id: object::id(&nft),
        });
        let NFTObject { id, name: _, image_url: _ } = nft;
        object::delete(id);
    }

}