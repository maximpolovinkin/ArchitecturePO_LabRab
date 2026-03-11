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

    func getMessageAndValidate()
}

final class SigningPresenter: ISigningPresenter {

    // Dependencies
    private let dataSource: ISigningDataSource
    private let privateKey: Curve25519.Signing.PrivateKey = .init()
//    private let publicKey: String
    weak var view: ISigningView?

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

    func getMessageAndValidate() {
        dataSource.getPublicKey { result in
            switch result {
                case let .success(publicKeyResponce):
                self.dataSource.getMessage { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(data):
                            do {
                                let isValid = try self.verifySignature(
                                    message: data.message,
                                    signatureBase64: data.signature,
                                    publicKeyBase64: publicKeyResponce.publicKey
                                )
                                let title = isValid ? "Подпись верна" : "Подпись не верна"
                                self.view?.showAlert(title: title, message: data.message)
                            }
                            catch {
                                print(error)
                            }
                        case let .failure(error):
                            print(error)
                        }
                    }
                }
                case let .failure(error):
                   print(error)
            }
        }
    }

    // MARK: - Private

    private func verifySignature(
        message: String,
        signatureBase64: String,
        publicKeyBase64: String
    ) throws -> Bool {

        let messageData = Data(message.utf8)

        guard
            let signatureData = Data(base64Encoded: signatureBase64),
            let publicKeyData = Data(base64Encoded: publicKeyBase64)
        else {
            return false
        }

        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: publicKeyData)
        return publicKey.isValidSignature(
            signatureData,
            for: messageData
        )
    }
}
