// Note.swift

import Foundation
import SwiftyJSON

struct Note: JSONParsable {
    let id: UUID?
    let title: String
    let content: String
    let userID: UUID

    static func from(_ json: SwiftyJSON.JSON) -> Note? {
        let idString = json["id"].string
        let title = json["title"].stringValue
        let content = json["content"].stringValue
        let userIDString =  json["user"]["id"].string

        guard
            !title.isEmpty,
            !content.isEmpty,
            let userIDString,
            let userID = UUID(uuidString: userIDString)
        else {
            return nil
        }

        let id = idString.flatMap { UUID(uuidString: $0) }

        return Note(id: id, title: title, content: content, userID: userID)
    }
}

struct NotesList: JSONParsable {
    let notes: [Note]

    static func from(_ json: SwiftyJSON.JSON) -> NotesList? {
        let arrayJSON: [SwiftyJSON.JSON]
        if json.array != nil {
            arrayJSON = json.arrayValue
        } else {
            arrayJSON = json["notes"].arrayValue
        }

        let notes = arrayJSON.compactMap { Note.from($0) }
        return NotesList(notes: notes)
    }
}
