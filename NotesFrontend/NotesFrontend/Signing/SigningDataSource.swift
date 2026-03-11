//
//  SigningDataSource.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import Foundation

protocol ISigningDataSource {
    func verifySignature(
        message: String,
        signatureBase64: String,
        publicKeyBase64: String,
        completion: @escaping (Result<VerifyResponse, NSError>) -> Void
    )

    func getMessage(completion: @escaping (Result<GetMessageResponce, NSError>) -> Void)
    func getPublicKey(
       completion: @escaping (Result<PublicKeyResponse, NSError>) -> Void
    )
}

final class SigningDataSource: ISigningDataSource {

    // Dependencies
    private let verifyProcessor: RequestProcessor<VerifyResponse>
    private let getMessageProcessor: RequestProcessor<GetMessageResponce>
    private let publicKeyProcessor: RequestProcessor<PublicKeyResponse>

    // MARK: - Initialization

    init(
        processor: RequestProcessor<VerifyResponse>,
        getMessageProcessor: RequestProcessor<GetMessageResponce>,
        publicKeyProcessor: RequestProcessor<PublicKeyResponse>
    ) {
        self.verifyProcessor = processor
        self.getMessageProcessor = getMessageProcessor
        self.publicKeyProcessor = publicKeyProcessor
    }

    // MARK: - ISigningDataSource

    func verifySignature(
        message: String,
        signatureBase64: String,
        publicKeyBase64: String,
        completion: @escaping (Result<VerifyResponse, NSError>) -> Void
    ) {
        let request = makeVerifyRequest(
            message: message,
            signatureBase64: signatureBase64,
            publicKeyBase64: publicKeyBase64
        )
        verifyProcessor.execute(request: request, completion: completion)
    }

    func getMessage(
        completion: @escaping (Result<GetMessageResponce, NSError>) -> Void
    ) {
        let request = makeGetMessageRequest()
        getMessageProcessor.execute(request: request, completion: completion)
    }

    func getPublicKey(
       completion: @escaping (Result<PublicKeyResponse, NSError>) -> Void
    ) {
        let request = makeGetPublicKeyRequest()
        publicKeyProcessor.execute(request: request, completion: completion)
    }

    // MARK: - Private

    private func makeVerifyRequest(
        message: String,
        signatureBase64: String,
        publicKeyBase64: String
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/verify")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "message": message,
            "signature": signatureBase64,
            "publicKey": publicKeyBase64
        ])
        return request
    }

    private func makeGetMessageRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/signedMessage")!)
        request.httpMethod = "GET"
        return request
    }

    private func makeGetPublicKeyRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/publicKey")!)
        request.httpMethod = "GET"
        return request
    }
}

