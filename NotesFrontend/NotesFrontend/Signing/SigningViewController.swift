//
//  SigningViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import UIKit

final class SigningViewController: UIViewController {

    // Components
    private let textField = UITextField()
    private let button = UIButton(type: .system)
    private let resultLabel = UILabel()

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
        setupButton()
        setupLabel()
        setupStack()
    }

    private func setupTextField() {
        textField.placeholder = "Сообщение"
        textField.borderStyle = .roundedRect
    }

    private func setupButton() {
        button.setTitle("Подписать и отправить", for: .normal)
        button.configuration = .glass()
        button.backgroundColor = .systemMint
        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
    }

    private func setupLabel() {
        resultLabel.textAlignment = .center
        resultLabel.textColor = .secondaryLabel
        resultLabel.numberOfLines = 0
    }

    private func setupStack() {
        let stack = UIStackView(arrangedSubviews: [
            textField,
            button,
            resultLabel
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func onButtonTap() {
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
}

