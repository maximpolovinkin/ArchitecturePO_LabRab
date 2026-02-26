import Fluent
import Vapor

final class Note: Model, Content, @unchecked Sendable {
    static let schema = "notes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "content")
    var content: String

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil, title: String, content: String, userID: UUID) {
        self.id = id
        self.title = title
        self.content = content
        self.$user.id = userID
    }
}
