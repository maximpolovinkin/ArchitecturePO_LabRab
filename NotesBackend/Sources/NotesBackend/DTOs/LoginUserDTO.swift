//
//  LoginUserDTO.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import Vapor

struct LoginUserDTO: Content {
    let login: String
    let password: String
}
