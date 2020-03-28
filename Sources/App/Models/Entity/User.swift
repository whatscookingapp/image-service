import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?

    init() { }
}
