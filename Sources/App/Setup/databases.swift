import Vapor
import FluentPostgreSQL

public func databases(config: inout DatabasesConfig) throws {
    guard let databaseUrl: String = Environment.get("DATABASE_URL") else {
        throw Abort(.internalServerError)
    }
    guard let dbConfig = PostgreSQLDatabaseConfig(url: databaseUrl) else {
        throw Abort(.internalServerError)
    }
    config.enableLogging(on: .psql)
    config.add(database: PostgreSQLDatabase(config: dbConfig), as: .psql)
}
