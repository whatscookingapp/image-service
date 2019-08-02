import Vapor
import FluentPostgreSQL

protocol ImageRepository: ServiceType {
    func find(id: UUID, on connectable: DatabaseConnectable) -> Future<Image?>
    func save(image: Image, on connectable: DatabaseConnectable) -> Future<Image>
}

final class PostgreImageRepository: ImageRepository {
    
    let database: PostgreSQLDatabase.ConnectionPool
    
    init(_ database: PostgreSQLDatabase.ConnectionPool) {
        self.database = database
    }
    
    func find(id: UUID, on connectable: DatabaseConnectable) -> Future<Image?> {
        return Image.query(on: connectable).filter(\.id == id).first()
    }
    
    func save(image: Image, on connectable: DatabaseConnectable) -> Future<Image> {
        return image.save(on: connectable)
    }
}

//MARK: - ServiceType conformance
extension PostgreImageRepository {
    static let serviceSupports: [Any.Type] = [ImageRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .psql))
    }
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
