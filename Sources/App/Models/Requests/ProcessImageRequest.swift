import Vapor

struct ProcessImageRequest: Content {
    
    let bucket: String
    let key: String
    let edits: ImageEdits
}

struct ImageEdits: Content {
    
    let resize: ImageResize
}

struct ImageResize: Content {
    
    let width: Int
    let height: Int?
    let fit: ImageFit
}

enum ImageFit: String, Content {
    case cover
}
