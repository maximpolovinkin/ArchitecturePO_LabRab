//
//  PublicKeyResponse.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 11/03/2026.
//

import SwiftyJSON

struct PublicKeyResponse: JSONParsable {
    let publicKey: String

    static func from(_ json: JSON) -> PublicKeyResponse? {
        guard let publicKey = json["publicKey"].string else {
            return nil
        }

        return PublicKeyResponse(publicKey: publicKey)
    }
}
