import Vapor
import FluentPostgresDriver

protocol ImageRepository {

    func find(id: UUID, on req: Request) -> EventLoopFuture<Image?>
    func save(image: Image, on req: Request) -> EventLoopFuture<Image>
}

struct ImageRepositoryImpl: ImageRepository {
    
    func find(id: UUID, on req: Request) -> EventLoopFuture<Image?> {
        return Image.query(on: req.db).filter(\.$id == id).first()
    }
    
    func save(image: Image, on req: Request) -> EventLoopFuture<Image> {
        return image.save(on: req.db).map { image }
    }
}
