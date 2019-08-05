import Vapor
import S3

struct ImageController: RouteCollection {
    
    func boot(router: Router) throws {
        let imagesRouter = router.grouped("images")
        
        imagesRouter.post(ImageRequest.self, at: "", use: generateImage)
        imagesRouter.get(UUID.parameter, use: getImage)
    }
}

private extension ImageController {
    
    func generateImage(_ req: Request, request: ImageRequest) throws -> Future<CreateImageResponse> {
        try request.validate()
        guard let bucket: String = Environment.get("AWS_BUCKET") else {
            throw Abort(.internalServerError)
        }
        let s3Signer = try req.make(S3Signer.self)
        let fileName = UUID().uuidString + ".jpg"
        let s3 = try req.makeS3Client()
        let upload = File.Upload(data: Data(), destination: fileName, access: .publicRead)
        let url = try s3.url(fileInfo: upload, on: req)
        let headers: [String: String] = ["x-amz-acl": AccessControlList.publicRead.rawValue, "Content-Length": "\(request.bytes)"]
        guard let presignedURL = try s3Signer.presignedURL(for: .PUT, url: url, expiration: .fifteenMinutes, region: nil, headers: headers) else {
            throw Abort(.internalServerError)
        }
        let image = Image(bucket: bucket, key: fileName)
        let repository = try req.make(ImageRepository.self)
        return repository.save(image: image, on: req).map { image in
            return CreateImageResponse(id: try image.requireID(), url: presignedURL, headers: headers)
        }
    }
    
    func getImage(_ req: Request) throws -> Future<GetImageResponse> {
        let id = try req.parameters.next(UUID.self)
        let repository = try req.make(ImageRepository.self)
        return repository.find(id: id, on: req).unwrap(or: Abort(.notFound)).map(to: GetImageResponse.self) { image in
            return GetImageResponse(id: try image.requireID())
        }
    }
}
