import Vapor

struct CreateImageResponse: Content {
    
    let id: UUID
    let url: URL
}
