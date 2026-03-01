import Vapor

struct RegisterResponceUserDTO: Content {
    let id: UUID
    let role: UserRole
}
