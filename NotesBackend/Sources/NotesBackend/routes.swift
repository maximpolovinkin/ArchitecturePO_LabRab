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
        guard let idString = request.headers.first(name: "X-User-ID"),
              let uuid = UUID(uuidString: idString)
        else {
            throw Abort(.unauthorized)
        }

        return User.find(uuid, on: request.db)
            .unwrap(or: Abort(.unauthorized))
            .flatMap { user in
                guard user.role == .admin || user.role == .moderator else {
                    return request.eventLoop.makeFailedFuture(Abort(.forbidden))
                }

                return Note.query(on: request.db).all()
            }
    }

    // edit note by id
    app.put("editNote", ":noteID") { request async throws -> Note in

        let updatedDTO = try request.content.decode(NoteDTO.self)

        guard let noteID = request.parameters.get("noteID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let idString = request.headers.first(name: "X-User-ID"),
              let uuid = UUID(uuidString: idString),
              let user = try await User.find(uuid, on: request.db)
        else {
            throw Abort(.unauthorized)
        }

        guard user.role == .admin || user.role == .moderator else {
            throw Abort(.forbidden)
        }

        guard let note = try await Note.find(noteID, on: request.db) else {
            throw Abort(.notFound)
        }

        note.title = updatedDTO.title
        note.content = updatedDTO.content

        try await note.save(on: request.db)
        return note
    }

    // delete note by id
    app.delete("deleteNote", ":noteId") { request -> EventLoopFuture<Note> in
        guard let noteID = request.parameters.get("noteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid noteID")
        }

        guard let idString = request.headers.first(name: "X-User-ID"),
              let uuid = UUID(uuidString: idString)
        else {
            throw Abort(.unauthorized)
        }

        let noteToDelete = Note.find(noteID, on: request.db).unwrap(or: Abort(.notFound))

        return User.find(uuid, on: request.db)
            .unwrap(or: Abort(.unauthorized))
            .flatMap { user in
                guard user.role == .admin else {
                    return request.eventLoop.makeFailedFuture(Abort(.forbidden))
                }

                return noteToDelete.flatMap { note in
                    note.delete(on: request.db).map { note }
                }
            }
    }

    // MARK: - Users routes

    // registration
    app.post("register") { request async throws -> String in
        let data = try request.content.decode(RegistrationUserDTO.self)

        let count = try await User.query(on: request.db).count()
        var role: UserRole = .user

        if count == 0 {
            role = .admin
        } else if count == 1 {
            role = .moderator
        }

        let hash = try Bcrypt.hash(data.password)

        let user = User(
            login: data.login,
            role: role,
            passwordHash: hash
        )

        try await user.save(on: request.db)
        return role.rawValue
    }

    // login
    app.post("login") { request -> EventLoopFuture<LoginResponceUserDTO> in
        let data = try request.content.decode(LoginUserDTO.self)

        return User.query(on: request.db)
            .filter(\.$login == data.login)
            .first()
            .unwrap(or: Abort(.unauthorized))
            .flatMapThrowing { user in

                if try Bcrypt.verify(data.password, created: user.passwordHash) {
                    return LoginResponceUserDTO(
                        login: user.login,
                        role: user.role.rawValue
                    )
                } else {
                    throw Abort(.unauthorized)
                }
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

 curl -X POST http://localhost:8080/register \
 -H "Content-Type: application/json" \
 -d '{"login":"moder","password":"moder"}'

 curl -X POST http://localhost:8080/register \
 -H "Content-Type: application/json" \
 -d '{"login":"admin","password":"admin"}'


 curl -X POST http://localhost:8080/login \
 -H "Content-Type: application/json" \
 -d '{"login":"admin","password":"admin"}'

 // данные для входа в админскую версию - admin admin
 */
