module version::version {
    use sui::table;
    use sui::package;
    use sui::package::Publisher;
    use std::type_name;
    use sui::address;
    use std::ascii;
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::object;

    struct VERSION has drop{}

    // id 0xf39535ec8b7857cd23d34183b2166e0400ca1a4a8a0e58e293377aef184a561d
    struct Version has key{
        id: UID,
        versions: table::Table<address, u64>
    }

    fun init(witness:VERSION,ctx: &mut TxContext){
        package::claim_and_keep(witness,ctx);
        transfer::share_object(Version{
            id: object::new(ctx),
            versions: table::new(ctx)
        })
    }

    public entry fun add<K>(publisher: &Publisher , global_version : &mut Version) {
        assert!(package::from_package<K>(publisher), 1);
        let package =  type_name::get_address(&type_name::get<K>());
        let addr = address::from_bytes(ascii::into_bytes(package));
        table::add(&mut global_version.versions, addr,0);
    }

    public entry fun set<K>(publisher: &Publisher , global_version : &mut Version, version: u64) {
        assert!(package::from_package<K>(publisher), 1);
        let package =  type_name::get_address(&type_name::get<K>());
        let addr = address::from_bytes(ascii::into_bytes(package));
        *table::borrow_mut(&mut global_version.versions, addr) = version;
    }

    public fun get( global_version : & Version, addr: address): u64 {
        *table::borrow(& global_version.versions, addr)
    }

    public fun borrow_mut<K>(publisher: &Publisher , global_version : &mut Version): &mut u64 {
        assert!(package::from_package<K>(publisher), 1);
        let package =  type_name::get_address(&type_name::get<K>());
        let addr = address::from_bytes(ascii::into_bytes(package));
        table::borrow_mut(&mut global_version.versions, addr)
    }

    public fun contains<K>( global_version : & Version, addr: address): bool {
        table::contains(& global_version.versions, addr)
    }
}
