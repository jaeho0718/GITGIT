//
//  AsyncImage.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/25.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: NSImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    private var cache: ImageCache?
    private(set) var isLoading = false
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
        

    deinit {
        cancel()
    }
    
    func load() {
            // 2.
        guard !isLoading else { return }

        if let image = cache?[url] {
            self.image = image
            return
        }
            
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { NSImage(data: $0.data) }
            .replaceError(with: nil)
            .subscribe(on: Self.imageProcessingQueue)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                              receiveOutput: { [weak self] in self?.cache($0) },
                              receiveCompletion: { [weak self] _ in self?.onFinish() },
                              receiveCancel: { [weak self] in self?.onFinish() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
        }
        
    func cancel() {
        cancellable?.cancel()
    }
    
    private func cache(_ image: NSImage?) {
        image.map { cache?[url] = $0 }
    }
    
    private func onStart() {
        isLoading = true
    }
        
    private func onFinish() {
        isLoading = false
    }
}

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (NSImage) -> Image
    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (NSImage) -> Image = Image.init(nsImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group{
            if loader.image != nil {
                Image(nsImage: loader.image!)
                    .resizable().aspectRatio(contentMode: .fill)
            } else {
                placeholder
            }
        }
    }
}
