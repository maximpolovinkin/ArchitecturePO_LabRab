//
//  AutorisationService.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import Foundation

protocol IAutorisationService {
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, NSError>) -> Void
    )
    func register(
        email: String,
        password: String,
        completion: @escaping (Result<User, NSError>) -> Void
    )
}

final class AutorisationService: IAutorisationService {

    // Dependencies
    private let requestProcessor: RequestProcessor<User>

    // MARK: - Initialization

    init(requestProcessor: RequestProcessor<User>) {
        self.requestProcessor = requestProcessor
    }

    // MARK: - IAutorisationService

    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, NSError>) -> Void
    ) {
        let request = makeLogInRequest(email: email, password: password)
        requestProcessor.execute(request: request, completion: completion)
    }

    func register(
        email: String,
        password: String,
        completion: @escaping (Result<User, NSError>) -> Void
    ) {
        let request = makeSignUpRequest(email: email, password: password)
        requestProcessor.execute(request: request, completion: completion)
    }

    // MARK: - Private

    private func makeLogInRequest(email: String, password: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/login")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "login": email,
            "password": password
        ])
        return request
    }

    private func makeSignUpRequest(email: String, password: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/register")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "login": email,
            "password": password
        ])
        return request
    }
}
