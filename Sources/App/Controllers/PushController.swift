import Vapor
import OneSignal

struct PushController: RouteCollection {
    
    func boot(router: Router) throws {
        let pushRouter = router.grouped("push")
        
        pushRouter.post(SendPushRequest.self, at: "", use: send)
    }
}

private extension PushController {
    
    func send(_ req: Request, sendRequest: SendPushRequest) throws -> Future<HTTPStatus> {
        let oneSignalApp = try req.make(OneSignalApp.self)
        let oneSignal = try OneSignal.makeService(for: req)
        var notification = OneSignalNotification(message: sendRequest.description)
        notification.title = OneSignalMessage(sendRequest.title)
        notification.externalUserIds = sendRequest.recipients.map { $0.uuidString }
        return try oneSignal.send(notification: notification, toApp: oneSignalApp).map(to: HTTPStatus.self, { (result) -> HTTPStatus in
            switch result {
            case .success: return .ok
            default: return .internalServerError
            }
        })
    }
}
