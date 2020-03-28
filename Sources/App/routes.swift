import Vapor

func routes(_ app: Application) throws {
    
    app.get("status") { req -> HTTPStatus in
        return .ok
    }
    
    try app.register(collection: ImageController(imageRepository: ImageRepositoryImpl()))
}
