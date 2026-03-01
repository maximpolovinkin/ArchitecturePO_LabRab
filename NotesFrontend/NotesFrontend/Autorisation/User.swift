//
//  User.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import SwiftyJSON
import Foundation

struct User: JSONParsable {
    let id: UUID
    let role: String

    static func from(_ json: SwiftyJSON.JSON) -> User? {
        let idString = json["id"].stringValue
        let role = json["role"].stringValue

        guard
            let id = UUID(uuidString: idString),
            !role.isEmpty
        else {
            return nil
        }

        return User(id: id, role: role)
    }
}
