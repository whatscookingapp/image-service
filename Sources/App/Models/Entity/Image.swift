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
