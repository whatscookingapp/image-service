import Vapor
import FluentPostgreSQL
import ServiceExt
import S3
import OAuthValidator

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    Environment.dotenv()
    
    services.register { container -> NIOServerConfig in
        switch container.environment {
        case .production: return .default()
        default: return .default(port: 8088)
        }
    }
    
    try services.register(FluentPostgreSQLProvider())
    
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }
    
    /// Register middlewares
    var middlewaresConfig = MiddlewareConfig()
    try middlewares(config: &middlewaresConfig)
    services.register(middlewaresConfig)
    
    var databasesConfig = DatabasesConfig()
    try databases(config: &databasesConfig)
    services.register(databasesConfig)
    
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(migrations: &migrationConfig)
        return migrationConfig
    }
    
    setupRepositories(services: &services, config: &config)
    
    services.register { container in
        return UserIdCache()
    }
    
    /// S3
    guard let awsAccessKey: String = Environment.get("AWS_ACCESS_KEY"),
        let awsSecretKey: String = Environment.get("AWS_SECRET_KEY"),
        let awsBucket: String = Environment.get("AWS_BUCKET"),
        let awsRegionString: String = Environment.get("AWS_REGION") else {
            throw Abort(.internalServerError)
    }
    let regionName = Region.Name(awsRegionString)
    let region = Region(name: regionName)
    let signer = S3Signer.Config(accessKey: awsAccessKey, secretKey: awsSecretKey, region: region)
    try services.register(s3: signer, defaultBucket: awsBucket)
}
