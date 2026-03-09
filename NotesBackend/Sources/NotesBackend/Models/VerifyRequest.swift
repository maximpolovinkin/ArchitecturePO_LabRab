//
//  VerifyRequest.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import Vapor

struct VerifyRequest: Content {
    let message: String
    let signature: String
    let publicKey: String
}

struct VerifyResponse: Content {
    let valid: Bool
}
