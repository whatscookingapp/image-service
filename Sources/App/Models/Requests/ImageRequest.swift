import Vapor

struct ImageRequest: Content, Reflectable {
    
    let bytes: Int
}

extension ImageRequest: Validatable {
    
    static func validations() throws -> Validations<ImageRequest> {
        var validations = Validations(ImageRequest.self)
        try validations.add(\.bytes, .range(...5242880))
        return validations
    }
}
