//
//  SignedResponse.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 11/03/2026.
//


import Vapor

struct SignedResponse: Content {
    let message: String
    let signature: String
}