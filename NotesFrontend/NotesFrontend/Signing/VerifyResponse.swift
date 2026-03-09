//
//  VerifyResponse.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import SwiftyJSON

struct VerifyResponse: JSONParsable {
    let valid: Bool

    static func from(_ json: SwiftyJSON.JSON) -> VerifyResponse? {
        VerifyResponse(valid: json["valid"].boolValue)
    }
}
