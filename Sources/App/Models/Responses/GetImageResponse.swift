import Vapor

struct GetImageResponse: Content {
    
    let id: UUID
    let bucket: String
    let key: String
    
    init(image: Image) throws {
        self.id = try image.requireID()
        self.bucket = image.bucket
        self.key = image.key
    }
}
