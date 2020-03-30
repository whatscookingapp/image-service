import Fluent
import FluentPostgresDriver
import Vapor
import S3Signer
import S3Kit

// Called before your application initializes.
public func configure(_ app: Application) throws {
    if app.environment == .development {
        app.server.configuration.port = 8081
    }
    
    if let databaseURLString = Environment.get("DATABASE_URL"), let databaseURL = URL(string: databaseURLString) {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else if let databaseHost = Environment.get("DATABASE_HOST"),
        let databaseUser = Environment.get("DATABASE_USER"),
        let database = Environment.get("DATABASE"),
        let databasePassword = Environment.get("DATABASE_PASSWORD"),
        let databasePort = Environment.get("DATABASE_PORT"),
        let databasePortInt = Int(databasePort),
        let databaseCertificate = Environment.get("DATABASE_CERTIFICATE") {
        let certificate = try NIOSSLCertificate.init(bytes: Array(databaseCertificate.utf8), format: .pem)
        let databaseConfig = PostgresConfiguration(hostname: databaseHost, port: databasePortInt, username: databaseUser, password: databasePassword, database: database, tlsConfiguration: .forClient(trustRoots: .certificates([certificate])))
        app.databases.use(.postgres(configuration: databaseConfig), as: .psql)
    } else {
        throw Abort(.internalServerError, reason: "Database credentials not configured")
    }

    // Configure migrations
    app.migrations.add(CreateImage())
    
    if app.environment == .development {
        try app.autoMigrate().wait()
    }
    
    try routes(app)
}

extension Application {
    
    func makeS3() throws -> S3 {
        guard let bucket = Environment.get("AWS_BUCKET") else {
            throw Abort(.internalServerError, reason: "AWS not configured")
        }
        return try .init(defaultBucket: bucket, signer: try makeS3Signer())
    }
    
    func makeS3Signer() throws -> S3Signer {
        guard let accessKey = Environment.get("AWS_ACCESS_KEY"),
            let secretKey = Environment.get("AWS_SECRET_KEY"),
            let regionString = Environment.get("AWS_REGION") else {
                throw Abort(.internalServerError, reason: "AWS not configured")
        }
        let region = Region(name: .init(regionString))
        return try .init(.init(accessKey: accessKey, secretKey: secretKey, region: region))
    }
}
