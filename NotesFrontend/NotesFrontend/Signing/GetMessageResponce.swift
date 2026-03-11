//
//  GetMessageResponce.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 11/03/2026.
//

import SwiftyJSON

struct GetMessageResponce: JSONParsable {
    let message: String
    let signature: String

    static func from(_ json: SwiftyJSON.JSON) -> GetMessageResponce? {
        GetMessageResponce(
            message: json["message"].stringValue,
            signature: json["signature"].stringValue
        )
    }
}
