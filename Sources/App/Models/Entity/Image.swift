import Vapor
import FluentPostgreSQL

struct Image: PostgreSQLUUIDModel {
    
    static let createdAtKey: TimestampKey? = \Image.createdAt
    
    var id: UUID?
    var bucket: String
    var key: String
    var createdAt: Date?
    
    init(id: UUID? = nil, bucket: String, key: String) {
        self.id = id
        self.bucket = bucket
        self.key = key
    }
}

extension Image: Migration { }
extension Image: Content { }

extension Image {
    
    var thumbProcessReqeust: ProcessImageRequest {
        return ProcessImageRequest(bucket: bucket, key: key, edits: ImageEdits(resize: ImageResize(width: 100, height: 100, fit: .cover)))
    }
    
    var mediumProcessReqeust: ProcessImageRequest {
        return ProcessImageRequest(bucket: bucket, key: key, edits: ImageEdits(resize: ImageResize(width: 250, height: nil, fit: .cover)))
    }
    
    var largeProcessReqeust: ProcessImageRequest {
        return ProcessImageRequest(bucket: bucket, key: key, edits: ImageEdits(resize: ImageResize(width: 500, height: nil, fit: .cover)))
    }
}
