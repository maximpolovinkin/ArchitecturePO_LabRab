//
//  NotesPresenter.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import Foundation

protocol INotesPresenter: NSObjectProtocol {
    var notes: [Note] { get }
    var currentUser: User { get }
    func createNote(
        title: String,
        content: String,
        onSuccess: @escaping () -> Void
    )
    func editNote(
        noteID: UUID,
        title: String,
        content: String,
        onSuccess: @escaping () -> Void
    )
    func deleteNote(
        noteID: UUID,
        onSuccess: @escaping () -> Void
    )
}

final class NotesPresenter: NSObject, INotesPresenter {

    // Dependencies
    private let dataSource: INotesDataSource
    let currentUser: User
    weak var view: INotesView?

    // State
    private(set) var notes: [Note] = []

    // MARK: - Initialization

    init(
        dataSource: INotesDataSource,
        currentUser: User
    ) {
        self.dataSource = dataSource
        self.currentUser = currentUser
    }

    // MARK: - Internal

    func bootstrap() {
        loadNotes(
            onSuccess: { [weak self] in
                self?.view?.reloadData()
            }
        )
    }

    // MARK: - INotesPresenter

    func loadNotes(
        onSuccess: @escaping () -> Void
    ) {
        let role = currentUser.role.lowercased()

        if role == "admin" || role == "moderator" {
            dataSource.getAllNotes(userID: currentUser.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let notes):
                        self?.notes = notes
                        onSuccess()
                    case .failure(let error):
                       print(error)
                    }
                }
            }
        } else {
            dataSource.getNotes(userID: currentUser.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let notes):
                        self?.notes = notes
                        onSuccess()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }

    func createNote(
        title: String,
        content: String,
        onSuccess: @escaping () -> Void
    ) {
        let note = Note(id: nil, title: title, content: content, userID: currentUser.id)

        dataSource.saveNote(note) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedNote):
                    self?.notes.append(savedNote)
                    onSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func editNote(
        noteID: UUID,
        title: String,
        content: String,
        onSuccess: @escaping () -> Void
    ) {
        dataSource.editNote(
            noteID: noteID,
            title: title,
            content: content,
            userID: currentUser.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedNote):
                    if let index = self?.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                        self?.notes[index] = updatedNote
                    }
                    onSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func deleteNote(
        noteID: UUID,
        onSuccess: @escaping () -> Void
    ) {
        dataSource.deleteNote(noteID: noteID, userID: currentUser.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.notes.removeAll { $0.id == noteID }
                    onSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

