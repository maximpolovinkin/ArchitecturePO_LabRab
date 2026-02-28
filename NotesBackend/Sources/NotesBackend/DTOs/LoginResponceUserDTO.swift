//
//  LoginResponceUserDTO.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import Vapor

struct LoginResponceUserDTO: Content {
    let login: String
    let role: String
}
