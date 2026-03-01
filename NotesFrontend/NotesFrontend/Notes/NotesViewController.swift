//
//  NotesViewController.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import UIKit

protocol INotesView: NSObject {
    func reloadData()
    func showError(_ error: NSError)
}

final class NotesViewController: UIViewController, INotesView {

    // Components
    private let tableView = UITableView()
    private let addButton = UIButton()

    // Dependencies
    private let presenter: INotesPresenter?

    // Data
    private var notes: [Note] {
        presenter?.notes ?? []
    }

    // MARK: - Initialization

    init(presenter: INotesPresenter) {
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

    // MARK: - INotesView

    func reloadData() {
        tableView.reloadData()
    }

    func showError(_ error: NSError) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = .white

        setupTable()
        setupAddButton()
    }

    private func setupAddButton() {
        view.addSubview(addButton)
        addButton.configuration = .glass()
        addButton.backgroundColor = .systemYellow
        addButton.setTitle("Новая заметка", for: .normal)
        addButton.addTarget(self, action: #selector(onAddButtonTap), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 150),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupTable() {
        view.addSubview(tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func onChangeButtonTap(at indexPath: IndexPath) {
        guard let noteID = notes[indexPath.row].id else { return }

        let alert = makeNewDataAlert { title, content in
            self.presenter?.editNote(
                noteID: noteID,
                title: title,
                content: content,
                onSuccess: self.reloadData
            )
        }
        present(alert, animated: true)
    }

    private func onDeleteButtonTap(at indexPath: IndexPath) {
        guard let noteID = notes[indexPath.row].id else { return }
        presenter?.deleteNote(noteID: noteID, onSuccess: reloadData)
    }

    @objc private func onAddButtonTap() {
        let alert = makeNewDataAlert { title, content in
            self.presenter?.createNote(
                title: title,
                content: content,
                onSuccess: self.reloadData
            )
        }
        present(alert, animated: true)
    }

    private func makeNewDataAlert(onDoneTapAction: @escaping (String, String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Новые данные", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Заголовок" }
        alert.addTextField { $0.placeholder = "Записка" }

        let doneAction = UIAlertAction(title: "Готово", style: .default) { [weak alert] _ in
            let title = alert?.textFields?[0].text ?? ""
            let note = alert?.textFields?[1].text ?? ""
            onDoneTapAction(title, note)
        }

        alert.addAction(doneAction)
        alert.addAction(.init(title: "Отменить", style: .cancel))

        return alert
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none

        let note = notes[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = note.title
        content.secondaryText = note.content
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content

        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard presenter?.currentUser.role == "admin" || presenter?.currentUser.role == "moderator" else { return nil }

        var deleteAction: UIContextualAction?
        if presenter?.currentUser.role == "admin" {
            deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completion in
                self.onDeleteButtonTap(at: indexPath)
                completion(true)
            }
        }

        let edit = UIContextualAction(style: .normal, title: "Изменить") { _, _, completion in
            self.onChangeButtonTap(at: indexPath)
            completion(true)
        }
        edit.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, edit].compactMap { $0 })
    }
}
