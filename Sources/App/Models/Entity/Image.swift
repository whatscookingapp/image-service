import Fluent
import Vapor

final class Image: Model, Content {
    static let schema = "image"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?

    @Field(key: "bucket")
    var bucket: String
    
    @Field(key: "key")
    var key: String
    
    @Parent(key: "creator_id")
    var creator: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(bucket: String, key: String, creatorID: UUID) {
        self.bucket = bucket
        self.key = key
        self.$creator.id = creatorID
    }
}
