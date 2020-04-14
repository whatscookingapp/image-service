import Vapor

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
        guard createRequest.bytes < 10000000 else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        let signer = try req.application.makeS3Signer()
        
        guard let region = Environment.get("AWS_REGION") else { throw Abort(.internalServerError) }
        guard let bucket = Environment.get("AWS_BUCKET") else { throw Abort(.internalServerError) }
        
        let fileName = UUID().uuidString + ".jpg"
        guard let url = URL(string: "https://s3.\(region).amazonaws.com/\(bucket)/\(fileName)") else {
            throw Abort(.internalServerError)
        }
        let signedURL = signer.signURL(url: url, method: .PUT, expires: 60 * 15)
        let image = Image(bucket: bucket, key: fileName, creatorID: userID)
        return imageRepository.save(image: image, on: req).flatMapThrowing { image in
            return CreateImageResponse(id: try image.requireID(), url: signedURL)
        }
    }
}
