//
//  LoginResponceUserDTO.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import Vapor
import Foundation

struct LoginResponceUserDTO: Content {
    let id: UUID
    let role: String
}
