import Vapor

struct CreateImageResponse: Content {
    
    let id: UUID
    let url: URL
    let headers: [String: String]
}
