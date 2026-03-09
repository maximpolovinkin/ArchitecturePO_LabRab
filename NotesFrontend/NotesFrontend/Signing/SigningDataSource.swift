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
}

final class SigningDataSource: ISigningDataSource {

    // Dependencies
    private let processor: RequestProcessor<VerifyResponse>

    // MARK: - Initialization

    init(processor: RequestProcessor<VerifyResponse>) {
        self.processor = processor
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
        processor.execute(request: request, completion: completion)
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
}

