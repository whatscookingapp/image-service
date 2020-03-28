import Vapor
import S3Signer
import S3Kit

struct ImageController: RouteCollection {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func boot(routes: RoutesBuilder) throws {
        let imagesRoute = routes.grouped("images")
        
        imagesRoute.get(":id", use: fetchImage)
        imagesRoute.post("", use: generateImage)
    }
}

private extension ImageController {
    
    func fetchImage(_ req: Request) throws -> EventLoopFuture<GetImageResponse> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return imageRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMapThrowing { image in
            return try GetImageResponse(image: image)
        }
    }
    
    func generateImage(_ req: Request) throws -> EventLoopFuture<CreateImageResponse> {
        let createRequest = try req.content.decode(ImageRequest.self)
        let userID = try req.requireUserID()
        let s3 = try req.application.makeS3()
        guard let bucket = Environment.get("AWS_BUCKET") else { throw Abort(.internalServerError) }
        let fileName = UUID().uuidString + ".jpg"
        let upload = File.Upload(data: Data(), destination: fileName, access: .publicRead)
        let headers: [String: String] = ["Content-Length": "\(createRequest.bytes)"]
        let url = try s3.url(fileInfo: upload)
        guard let presignedURL = try s3.signer.presignedURL(for: .PUT, url: url, expiration: .fifteenMinutes, region: nil, headers: headers) else {
            throw Abort(.internalServerError)
        }
        let image = Image(bucket: bucket, key: fileName, creatorID: userID)
        return imageRepository.save(image: image, on: req).flatMapThrowing { image in
            return CreateImageResponse(id: try image.requireID(), url: presignedURL, headers: headers)
        }
    }
}

//import Vapor
//import OAuthValidator
//import scopes
//import S3
//
//struct ImageController: RouteCollection {
//    
//    func boot(router: Router) throws {
//        let imagesRouter = router.grouped("images")
//        imagesRouter.get(UUID.parameter, use: getImage)
//        
//        let authenticatedRouter = imagesRouter.grouped(UserIdMiddleware(), ScopeValidationMiddleware(scope: .image))
//        authenticatedRouter.post(ImageRequest.self, at: "", use: generateImage)
//    }
//}
//
//private extension ImageController {
//    
//    func getImage(_ req: Request) throws -> Future<GetImageResponse> {
//        let id = try req.parameters.next(UUID.self)
//        let repository = try req.make(ImageRepository.self)
//        return repository.find(id: id, on: req).unwrap(or: Abort(.notFound)).map(to: GetImageResponse.self) { image in
//            return GetImageResponse(id: try image.requireID())
//        }
//    }
//    
//    func generateImage(_ req: Request, request: ImageRequest) throws -> Future<CreateImageResponse> {
//        try request.validate()
//        guard let bucket: String = Environment.get("AWS_BUCKET") else {
//            throw Abort(.internalServerError)
//        }
//        let s3Signer = try req.make(S3Signer.self)
//        let fileName = UUID().uuidString + ".jpg"
//        let s3 = try req.makeS3Client()
//        let upload = File.Upload(data: Data(), destination: fileName, access: .publicRead)
//        let url = try s3.url(fileInfo: upload, on: req)
//        let headers: [String: String] = ["Content-Length": "\(request.bytes)"]
//        guard let presignedURL = try s3Signer.presignedURL(for: .PUT, url: url, expiration: .fifteenMinutes, region: nil, headers: headers) else {
//            throw Abort(.internalServerError)
//        }
//        let image = Image(bucket: bucket, key: fileName)
//        let repository = try req.make(ImageRepository.self)
//        return repository.save(image: image, on: req).map { image in
//            return CreateImageResponse(id: try image.requireID(), url: presignedURL, headers: headers)
//        }
//    }
//}
