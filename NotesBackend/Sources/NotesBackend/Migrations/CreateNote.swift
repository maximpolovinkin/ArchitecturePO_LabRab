import Fluent

struct CreateNote: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notes")
            .id()
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notes").delete()
    }
}
