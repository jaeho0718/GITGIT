//
//  Imagecash.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/25.
//

import SwiftUI
import Combine
import Foundation

protocol ImageCache {
    subscript(_ url: URL) -> NSImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, NSImage>()
    
    subscript(_ key: URL) -> NSImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
