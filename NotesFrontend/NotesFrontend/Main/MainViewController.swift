//
//  MainViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 09/03/2026.
//

import UIKit

final class MainViewController: UIViewController {

    // Components
    private let stackView = UIStackView()
    private let lab1Button = UIButton(type: .system)
    private let lab2Button = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStackView()
        setupButtons()
    }

    // MARK: - Private

    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
    }

    private func setupStackView() {
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupButtons() {
        configure(button: lab1Button, title: "Лабораторная 1", action: #selector(onLab1ButtonTap))
        configure(button: lab2Button, title: "Лабораторная 2", action: #selector(onLab2ButtonTap))
        lab1Button.backgroundColor = .systemCyan
        lab2Button.backgroundColor = .systemBlue

        stackView.addArrangedSubview(lab1Button)
        stackView.addArrangedSubview(lab2Button)

        [lab1Button, lab2Button].forEach { button in
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        }
    }

    private func configure(button: UIButton, title: String, action: Selector) {
        button.configuration = .glass()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Actions

    @objc private func onLab1ButtonTap() {
        let controller = makeAutorisationViewController()
        controller.title = "Лабораторная 1"
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func onLab2ButtonTap() {
        let controller = makeSigningViewController()
        controller.title = "Лабораторная 2"
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Factories

    private func makeAutorisationViewController() -> AutorisationViewController {
        let processor = RequestProcessor<User>()
        let service = AutorisationService(requestProcessor: processor)
        let presenter = AutorisationPresenter(autorisationService: service)
        return AutorisationViewController(presenter: presenter)
    }

    private func makeSigningViewController() -> SigningViewController {
        let processor = RequestProcessor<VerifyResponse>()
        let getMessageProcessor = RequestProcessor<GetMessageResponce>()
        let publicKeyProcessor = RequestProcessor<PublicKeyResponse>()
        let dataSource = SigningDataSource(
            processor: processor,
            getMessageProcessor: getMessageProcessor,
            publicKeyProcessor: publicKeyProcessor
        )
        let presenter = SigningPresenter(dataSource: dataSource)
        let controller = SigningViewController(presenter: presenter)

        presenter.view = controller

        return controller
    }
}

