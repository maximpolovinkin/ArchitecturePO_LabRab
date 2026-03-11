//
//  KeyService.swift
//  NotesBackend
//
//  Created by Maksim Polovinkin on 11/03/2026.
//

import Foundation
import CryptoKit
import Vapor

struct KeyServiceKey: StorageKey {
    typealias Value = KeyService
}

public final class KeyService: @unchecked Sendable {

    let privateKey: Curve25519.Signing.PrivateKey

    init() {
        self.privateKey = Curve25519.Signing.PrivateKey()
    }

    var publicKey: Curve25519.Signing.PublicKey {
        privateKey.publicKey
    }
}
