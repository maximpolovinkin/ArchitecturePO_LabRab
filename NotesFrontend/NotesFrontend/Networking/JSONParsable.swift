//
//  JSONParsable.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import SwiftyJSON

protocol JSONParsable {
    static func from(_ json: SwiftyJSON.JSON) -> Self?
}
