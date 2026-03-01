//
//  AutorisationViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 28/02/2026.
//

import UIKit

final class AutorisationViewController: UIViewController {

    // Components
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton()
    private let loginButton = UIButton()
    private let stackView = UIStackView()

    // Dependencies
    private let presenter: IAutorisationPresenter

    // MARK: - Initialization

    init(presenter: IAutorisationPresenter) {
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
        registerButton.addTarget(self, action: #selector(onRegisterButtonTap), for: .touchUpInside)
    }

    private func setupLoginButton() {
        loginButton.setTitle("Залогиниться", for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.borderColor = UIColor.blue.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.configuration = .plain()
        loginButton.addTarget(self, action: #selector(onLoginButtonTap), for: .touchUpInside)
    }

    private func setupHideKeyboardOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func presentNotes() {
        guard let controller = makeNotesVC() else { return }

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    private func showError(_ error: NSError) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func onLoginButtonTap() {
        let login = loginTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter.didTapLogin(
            login: login,
            password: password,
            onSuccess: { [weak self] _ in
                self?.presentNotes()
            },
            onError: { [weak self] error in
                self?.showError(error)
            }
        )
    }

    @objc private func onRegisterButtonTap() {
        let login = loginTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter.didTapRegister(
            login: login,
            password: password,
            onSuccess: { [weak self] _ in
                self?.presentNotes()
            },
            onError: { [weak self] error in
                self?.showError(error)
            }
        )
    }

    @objc private func onBackButtonTap() {
        dismiss(animated: true)
    }

    private func makeNotesVC() -> NotesViewController? {
        guard let currentUser = presenter.currentUser else { return nil }

        let noteProcessor = RequestProcessor<Note>()
        let notesProcessor = RequestProcessor<NotesList>()
        let dataSource = NotesDataSource(noteProcessor: noteProcessor, notesProcessor: notesProcessor)
        let presenter = NotesPresenter(dataSource: dataSource, currentUser: currentUser)
        let controller = NotesViewController(presenter: presenter)
        presenter.view = controller
        presenter.bootstrap()

        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Закрыть",
            style: .plain,
            target: self,
            action: #selector(onBackButtonTap)
        )

        return controller
    }
}

private extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach(addArrangedSubview)
    }
}

