//
//  AutorisationPresenter.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import Foundation

protocol IAutorisationPresenter {
    var currentUser: User? { get set }

    func didTapLogin(
        login: String,
        password: String,
        onSuccess: @escaping (User) -> Void,
        onError: @escaping (NSError) -> Void
    )
    func didTapRegister(
        login: String,
        password: String,
        onSuccess: @escaping (User) -> Void,
        onError: @escaping (NSError) -> Void
    )
}

final class AutorisationPresenter: IAutorisationPresenter {

    // Dependencies
    private let autorisationService: IAutorisationService

    // Properties
    var currentUser: User?

    // MARK: - Initialization

    init(autorisationService: IAutorisationService) {
        self.autorisationService = autorisationService
    }

    // MARK: - IAutorisationPresenter

    func didTapLogin(
        login: String,
        password: String,
        onSuccess: @escaping (User) -> Void,
        onError: @escaping (NSError) -> Void
    ) {
        autorisationService.logIn(email: login, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    onSuccess(user)
                case .failure(let error):
                    onError(error)
                }
            }
        }
    }

    func didTapRegister(
        login: String,
        password: String,
        onSuccess: @escaping (User) -> Void,
        onError: @escaping (NSError) -> Void
    ) {
        autorisationService.register(email: login, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    onSuccess(user)
                case .failure(let error):
                    onError(error)
                }
            }
        }
    }
}

