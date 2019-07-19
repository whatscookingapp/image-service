import Vapor
import SwiftGD
import S3

struct ImageController: RouteCollection {
    
    func boot(router: Router) throws {
        let imagesRouter = router.grouped("images")
        
        imagesRouter.post(ImageRequest.self, at: "", use: send)
    }
}

private extension ImageController {
    
    func send(_ req: Request, imageRequest: ImageRequest) throws -> Future<HTTPStatus> {
        guard let fileNamePart = imageRequest.file.split(separator: ".").first else { throw Abort(.badRequest) }
        let fileName = String(fileNamePart)
        let s3 = try req.makeS3Client()
        return try s3.get(file: imageRequest.file, on: req).flatMap(to: HTTPStatus.self, { (file) -> Future<HTTPStatus> in
            guard let mediaType = MediaType.parse(file.mime) else { throw Abort(.badRequest) }
            let imageType: ImportableFormat
            if mediaType == .jpeg {
                imageType = .jpg
            } else if mediaType == .png {
                imageType = .png
            } else {
                throw Abort(.badRequest)
            }
            let image = try Image(data: file.data, as: imageType)
            let thumbnailTask = try ImageController.resizeImageTask(size: .thumbnail, image: image, mediaType: mediaType, fileName: fileName, on: req)
            let mediumTask = try ImageController.resizeImageTask(size: .medium, image: image, mediaType: mediaType, fileName: fileName, on: req)
            let largeTask = try ImageController.resizeImageTask(size: .large, image: image, mediaType: mediaType, fileName: fileName, on: req)
            return [thumbnailTask, mediumTask, largeTask].flatten(on: req).transform(to: .ok)
        })
    }
    
    static func resizeImageTask(size: ImageSize, image: Image, mediaType: MediaType, fileName: String, on container: Container) throws -> Future<Void> {
        let finalImage: Image?
        if image.size.width > image.size.height, let resizedImage = image.resizedTo(height: size.desiredDimension) {
            if size.keepAspectRatio {
                finalImage = resizedImage
            } else {
                let offset = (resizedImage.size.width - size.desiredDimension) / 2
                finalImage = resizedImage.cropped(to: Rectangle(x: offset, y: 0, width: size.desiredDimension, height: size.desiredDimension))
            }
        } else if let resizedImage = image.resizedTo(width: size.desiredDimension) {
            if size.keepAspectRatio {
                finalImage = resizedImage
            } else {
                let offset = (resizedImage.size.height - size.desiredDimension) / 2
                finalImage = resizedImage.cropped(to: Rectangle(x: 0, y: offset, width: size.desiredDimension, height: size.desiredDimension))
            }
        } else {
            throw Abort(.internalServerError)
        }
        guard let imageData = try finalImage?.export(as: .jpg(quality: 100)) else {
            throw Abort(.internalServerError)
        }
        let newFileName = fileName + size.fileExtension + "." + mediaType.subType
        let upload = File.Upload(data: imageData, destination: newFileName, access: .publicRead)
        let s3 = try container.makeS3Client()
        return try s3.put(file: upload, on: container).transform(to: ())
    }
}
