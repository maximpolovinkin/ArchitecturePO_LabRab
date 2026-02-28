import Vapor
import Fluent
import struct Foundation.UUID

enum UserRole: String, Codable {
    case admin
    case user
    case moderator
}

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "login")
    var login: String

    @Field(key: "role")
    var role: UserRole

    @Field(key: "password_hash")
    var passwordHash: String

    init() {}

    init(
        id: UUID? = nil,
        login: String,
        role: UserRole,
        passwordHash: String
    ) {
        self.id = id
        self.login = login
        self.role = role
        self.passwordHash = passwordHash
    }
}
