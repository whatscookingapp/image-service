import Fluent
import FluentPostgresDriver
import Vapor
import AWSSDKSwiftCore

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
    
    func makeS3Signer() throws -> AWSSigner {
        guard let accessKey = Environment.get("AWS_ACCESS_KEY"),
            let secretKey = Environment.get("AWS_SECRET_KEY"),
            let regionString = Environment.get("AWS_REGION"),
            let region = Region(rawValue: regionString) else {
                throw Abort(.internalServerError, reason: "AWS not configured")
        }
        let credential = StaticCredential(accessKeyId: accessKey, secretAccessKey: secretKey)
        return AWSSigner(credentials: credential, name: "s3", region: region.rawValue)
    }
}
