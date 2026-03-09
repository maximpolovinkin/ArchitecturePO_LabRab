//
//  SigningPresenter.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import CryptoKit
import Foundation

protocol ISigningPresenter {
    func signMessage(
        _ message: String,
        onResult: @escaping (Bool) -> Void,
        onError: @escaping (NSError) -> Void
    )
}

final class SigningPresenter: ISigningPresenter {

    // Dependencies
    private let dataSource: ISigningDataSource
    private let privateKey: Curve25519.Signing.PrivateKey = .init()

    // MARK: - Initialization

    init(
        dataSource: ISigningDataSource
    ) {
        self.dataSource = dataSource
    }

    // MARK: - ISigningPresenter

    func signMessage(
        _ message: String,
        onResult: @escaping (Bool) -> Void,
        onError: @escaping (NSError) -> Void
    ) {
        guard let messageData = message.data(using: .utf8) else {
            onError(.init(domain: "SigningPresenter", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Не удалось преобразовать сообщение в данные."
            ]))
            return
        }

        do {
            let signature = try privateKey.signature(for: messageData)
            let signatureBase64 = signature.base64EncodedString()
            let publicKeyBase64 = privateKey.publicKey.rawRepresentation.base64EncodedString()

            dataSource.verifySignature(
                message: message,
                signatureBase64: signatureBase64,
                publicKeyBase64: publicKeyBase64
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        onResult(response.valid)
                    case .failure(let error):
                        onError(error)
                    }
                }
            }
        } catch {
            onError(error as NSError)
        }
    }
}
