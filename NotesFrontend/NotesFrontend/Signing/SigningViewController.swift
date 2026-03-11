//
//  SigningViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import UIKit

protocol ISigningView: NSObject {
    func showAlert(title: String, message: String)
}

final class SigningViewController: UIViewController {

    // Components
    private let textField = UITextField()
    private let signAndSendButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    private let reciveButton = UIButton(type: .system)

    // Dependencies
    private let presenter: ISigningPresenter

    // MARK: - Initialization

    init(presenter: ISigningPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(presenter:) instead")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        setupTextField()
        setupSignAndSendButton()
        setupLabel()
        setupReciveButton()
        setupStack()
    }

    private func setupTextField() {
        textField.placeholder = "Сообщение"
        textField.borderStyle = .roundedRect
    }

    private func setupSignAndSendButton() {
        signAndSendButton.setTitle("Подписать и отправить", for: .normal)
        signAndSendButton.configuration = .glass()
        signAndSendButton.backgroundColor = .systemMint
        signAndSendButton.addTarget(self, action: #selector(onSignAndSendButtonTap), for: .touchUpInside)
    }

    private func setupLabel() {
        resultLabel.textAlignment = .center
        resultLabel.textColor = .secondaryLabel
        resultLabel.numberOfLines = 0
    }

    private func setupReciveButton() {
        reciveButton.setTitle("Получить сообщение и проверить подпись", for: .normal)
        reciveButton.configuration = .glass()
        reciveButton.backgroundColor = .systemIndigo
        reciveButton.addTarget(self, action: #selector(onReciveButtonTap), for: .touchUpInside)
    }

    private func setupStack() {
        let stack = UIStackView(arrangedSubviews: [
            textField,
            signAndSendButton,
            resultLabel,
            reciveButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions

    @objc private func onSignAndSendButtonTap() {
        guard let message = textField.text, !message.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите сообщение перед отправкой.")
            return
        }

        resultLabel.text = "Подписываем сообщение"

        presenter.signMessage(
            message,
            onResult: { [weak self] isValid in
                let title = isValid ? "Успех" : "Неуспех"
                let message = isValid ? "Подпись подтверждена сервером." : "Сервер отверг подпись."
                self?.resultLabel.text = message
                self?.showAlert(title: title, message: message)
            },
            onError: { [weak self] error in
                self?.resultLabel.text = "Ошибка: \(error.localizedDescription)"
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        )
    }

    @objc private func onReciveButtonTap() {
        presenter.getMessageAndValidate()
    }
}

extension SigningViewController: ISigningView {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
