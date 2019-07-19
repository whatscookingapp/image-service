//
//  ImageSize.swift
//  App
//
//  Created by Jimmy Arts on 19/07/2019.
//

import Foundation

enum ImageSize {
    case thumbnail
    case medium
    case large
    
    var desiredDimension: Int {
        switch self {
        case .thumbnail: return 50
        case .medium: return 250
        case .large: return 500
        }
    }
    
    var keepAspectRatio: Bool {
        switch self {
        case .thumbnail: return false
        default: return true
        }
    }
    
    var fileExtension: String {
        switch self {
        case .thumbnail: return "_thumb"
        case .medium: return "_medium"
        case .large: return "_large"
        }
    }
}
