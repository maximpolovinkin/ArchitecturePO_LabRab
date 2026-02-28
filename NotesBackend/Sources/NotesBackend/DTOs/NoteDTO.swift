import Fluent
import Vapor

struct NoteDTO: Content {
    let title: String
    let content: String
    let userID: UUID

    func toModel() -> Note {
        Note(
            title: title,
            content: content,
            userID: userID
        )
    }
}
