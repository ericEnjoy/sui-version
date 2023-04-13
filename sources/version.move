module version::version {
    use sui::table;
    use sui::package;
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::object;
    use sui::package::Publisher;
    use std::ascii;
    use sui::hex;
    use sui::address;

    struct VERSION has drop{}

    // id 0x7651c281a2931614071628f3670e4de3d06d1c48fb3b03e418d2ab319356f2bd
    struct Version has key{
        id: UID,
        versions: table::Table<address, u64>
    }

    #[test_only]
    public fun init_for_test(ctx: &mut TxContext){
        init(VERSION{}, ctx)
    }

    fun init(witness:VERSION,ctx: &mut TxContext){
        package::claim_and_keep(witness,ctx);
        transfer::share_object(Version{
            id: object::new(ctx),
            versions: table::new(ctx)
        })
    }

    public entry fun add(publisher: &Publisher , global_version : &mut Version) {
        let addr = address::from_bytes(hex::decode(*ascii::as_bytes(package::published_package(publisher))));
        table::add(&mut global_version.versions, addr,0);
    }

    public entry fun set(publisher: &Publisher , global_version : &mut Version, version: u64) {
        let addr = address::from_bytes(hex::decode(*ascii::as_bytes(package::published_package(publisher))));
        *table::borrow_mut(&mut global_version.versions, addr) = version;
    }

    public fun get( global_version : & Version, addr: address): u64 {
        *table::borrow(& global_version.versions, addr)
    }

    public fun borrow_mut(publisher: &Publisher , global_version : &mut Version): &mut u64 {
        let addr = address::from_bytes(hex::decode(*ascii::as_bytes(package::published_package(publisher))));
        table::borrow_mut(&mut global_version.versions, addr)
    }

    public fun contains( global_version : & Version, addr: address): bool {
        table::contains(& global_version.versions, addr)
    }
}
