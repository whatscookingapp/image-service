import Fluent

struct CreateImage: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Image.schema)
            .id()
            .field("bucket", .string, .required)
            .field("key", .string, .required)
            .field("creator_id", .uuid, .references(User.schema, "id"))
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Image.schema).delete()
    }
}
