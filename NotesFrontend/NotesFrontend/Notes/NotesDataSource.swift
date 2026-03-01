//
//  NotesDataSource.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import Foundation

protocol INotesDataSource {
    func saveNote(_ note: Note, completion: @escaping (Result<Note, NSError>) -> Void)
    func getNotes(userID: UUID, completion: @escaping (Result<[Note], NSError>) -> Void)
    func getAllNotes(userID: UUID, completion: @escaping (Result<[Note], NSError>) -> Void)
    func editNote(
        noteID: UUID,
        title: String,
        content: String,
        userID: UUID,
        completion: @escaping (Result<Note, NSError>) -> Void
    )
    func deleteNote(
        noteID: UUID,
        userID: UUID,
        completion: @escaping (Result<Note, NSError>) -> Void
    )
}

final class NotesDataSource: INotesDataSource {

    // Dependencies
    private let noteProcessor: RequestProcessor<Note>
    private let notesProcessor: RequestProcessor<NotesList>

    // MARK: - Initialization

    init(
        noteProcessor: RequestProcessor<Note>,
        notesProcessor: RequestProcessor<NotesList>
    ) {
        self.noteProcessor = noteProcessor
        self.notesProcessor = notesProcessor
    }

    // MARK: - INotesDataSource

    func saveNote(_ note: Note, completion: @escaping (Result<Note, NSError>) -> Void) {
        let request = makeSaveNoteRequest(note: note)
        noteProcessor.execute(request: request, completion: completion)
    }

    func getNotes(userID: UUID, completion: @escaping (Result<[Note], NSError>) -> Void) {
        let request = makeGetNotesRequest(userID: userID)
        notesProcessor.execute(request: request) { result in
            completion(result.map { $0.notes })
        }
    }

    func getAllNotes(userID: UUID, completion: @escaping (Result<[Note], NSError>) -> Void) {
        let request = makeGetAllNotesRequest(userID: userID)
        notesProcessor.execute(request: request) { result in
            completion(result.map { $0.notes })
        }
    }

    func editNote(
        noteID: UUID,
        title: String,
        content: String,
        userID: UUID,
        completion: @escaping (Result<Note, NSError>) -> Void
    ) {
        let request = makeEditNoteRequest(
            noteID: noteID,
            title: title,
            content: content,
            userID: userID
        )
        noteProcessor.execute(request: request, completion: completion)
    }

    func deleteNote(
        noteID: UUID,
        userID: UUID,
        completion: @escaping (Result<Note, NSError>) -> Void
    ) {
        let request = makeDeleteNoteRequest(noteID: noteID, userID: userID)
        noteProcessor.execute(request: request, completion: completion)
    }

    // MARK: - Private

    private func makeSaveNoteRequest(note: Note) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/saveNote")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "title": note.title,
            "content": note.content,
            "userID": note.userID.uuidString
        ])
        return request
    }

    private func makeGetNotesRequest(userID: UUID) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/getNotes/\(userID.uuidString)")!)
        request.httpMethod = "GET"
        return request
    }

    private func makeGetAllNotesRequest(userID: UUID) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/getAllNotes")!)
        request.httpMethod = "GET"
        request.addValue(userID.uuidString, forHTTPHeaderField: "X-User-ID")
        return request
    }

    private func makeEditNoteRequest(
        noteID: UUID,
        title: String,
        content: String,
        userID: UUID
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/editNote/\(noteID.uuidString)")!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userID.uuidString, forHTTPHeaderField: "X-User-ID")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "title": title,
            "content": content,
            "userID": userID.uuidString
        ])
        return request
    }

    private func makeDeleteNoteRequest(noteID: UUID, userID: UUID) -> URLRequest {
        var request = URLRequest(url: URL(string: "http://localhost:8080/deleteNote/\(noteID.uuidString)")!)
        request.httpMethod = "DELETE"
        request.addValue(userID.uuidString, forHTTPHeaderField: "X-User-ID")
        return request
    }
}
