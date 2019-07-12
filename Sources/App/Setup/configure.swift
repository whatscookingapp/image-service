import Vapor
import ServiceExt
import OneSignal

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    Environment.dotenv()
    
    services.register { container -> NIOServerConfig in
        switch container.environment {
        case .production: return .default()
        default: return .default(port: 8087)
        }
    }
    
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }
    
    /// Register middlewares
    var middlewaresConfig = MiddlewareConfig()
    try middlewares(config: &middlewaresConfig)
    services.register(middlewaresConfig)
    
    guard let oneSignalApiKey: String = Environment.get("ONESIGNAL_API_KEY"),
        let oneSignalAppId: String = Environment.get("ONESIGNAL_APP_ID") else {
        throw Abort(.internalServerError)
    }
    let oneSignal = OneSignalApp(apiKey: oneSignalApiKey, appId: oneSignalAppId)
    services.register(oneSignal, as: OneSignalApp.self)
}

extension OneSignalApp: Service { }
