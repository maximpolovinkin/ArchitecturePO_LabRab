//
//  PublicKeyResponse.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 11/03/2026.
//


import Vapor

struct PublicKeyResponse: Content {
    let publicKey: String
}