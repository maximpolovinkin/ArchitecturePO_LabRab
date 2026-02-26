import Vapor
import Fluent
import struct Foundation.UUID

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "role")
    var role: String

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        role: String
    ) {
        self.id = id
        self.name = name
        self.role = role
    }
}
