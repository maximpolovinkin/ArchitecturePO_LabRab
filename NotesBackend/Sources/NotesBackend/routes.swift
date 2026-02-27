import Fluent
import Vapor

func routes(_ app: Application) throws {

    // MARK: - Notes routes

    // save new note
    app.post("saveNote") { request -> EventLoopFuture<Note> in
        let decodedNote = try request.content.decode(NoteDTO.self).toModel()

        return decodedNote.save(on: request.db).map { decodedNote }
    }

    // get all notes for current user
    // /getNotes/userID:UUID
    app.get("getNotes", ":userID") { request -> EventLoopFuture<[Note]> in
        guard let userID = request.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid userID")
        }

        return Note.query(on: request.db)
            .filter(\.$user.$id == userID)
            .all()
    }

    // get all notes in db
    app.get("getAllNotes") { request -> EventLoopFuture<[Note]> in
        return Note.query(on: request.db).all()
    }

    // edit note by id (overwrite title/content only)
    app.put("editNote", ":noteID") { request -> EventLoopFuture<Note> in
        let updatedDTO = try request.content.decode(NoteDTO.self)

        guard let noteID = request.parameters.get("noteID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid noteID")
        }

        return Note.find(noteID, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { note in
                note.title = updatedDTO.title
                note.content = updatedDTO.content

                return note.save(on: request.db).map { note }
            }
    }

    // delete note by id
    app.delete("deleteNote", ":noteId") { request -> EventLoopFuture<Note> in
        guard let noteID = request.parameters.get("noteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid noteID")
        }

        let noteToDelete = Note.find(noteID, on: request.db).unwrap(or: Abort(.notFound))

        return noteToDelete.flatMap { note in
            note.delete(on: request.db).map { note }
        }
    }
}


/*
 curl http://localhost:8080/getNotes/userID:UUID_СУЩЕСТВУЮЩЕГО_ЮЗЕРА

 curl -X PUT http://localhost:8080/editNote/UUID_ЗАМЕТКИ \
 -H "Content-Type: application/json" \
 -d '{
   "title": "Updated title",
   "content": "Updated content",
   "userID": "UUID_ТОГО_ЖЕ_ЮЗЕРА"
 }'


 curl -X DELETE http://localhost:8080/deleteNote/UUID_ЗАМЕТКИ
 */
