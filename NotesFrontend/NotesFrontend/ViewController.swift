//
//  ViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import UIKit

class ViewController: UIViewController {

    // Components
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton()
    private let loginButton = UIButton()
    private let stackView = UIStackView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupHideKeyboardOnTap()

        setupMainStack()
        setupLoginTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupRegisterButton()
    }

    private func setupMainStack() {
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12

        stackView.addArrangedSubviews(
            loginTextField,
            passwordTextField,
            registerButton,
            loginButton
        )

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])

        stackView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }

    private func setupLoginTextField() {
        loginTextField.placeholder = "Логин"
        loginTextField.textAlignment = .center
        loginTextField.borderStyle = .roundedRect
        loginTextField.autocapitalizationType = .none
        loginTextField.autocorrectionType = .no
        loginTextField.returnKeyType = .next
    }

    private func setupPasswordTextField() {
        passwordTextField.placeholder = "Пароль"
        passwordTextField.textAlignment = .center
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .done
    }

    private func setupRegisterButton() {
        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.layer.borderColor = UIColor.blue.cgColor
        registerButton.layer.borderWidth = 1
        registerButton.configuration = .plain()
    }

    private func setupLoginButton() {
        loginButton.setTitle("Залогиниться", for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.borderColor = UIColor.blue.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.configuration = .plain()
    }

    private func setupHideKeyboardOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach(addArrangedSubview)
    }
}
