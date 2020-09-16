//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 9/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI
import Combine

// View Model
class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    
    // make class Hashable and Identifiable
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
        // combine hashable things (unique) to make type hashable
        hasher.combine(id)
    }
    
    static let palette: String = "👙🌂👑👘👔👠"
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    @Published private(set) var backgroundImage: UIImage?
    @Published private var emojiArt: EmojiArt
    
//    @Published private var emojiArt: EmojiArt {
//
//        willSet{
//            objectWillChange.send()
//        }
//        didSet {
//            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)   // save to persistent dict
//        }
//    }
    
    private var autosaveCancellable: AnyCancellable?    // type erased of Cancellable
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()  // defaulting here: init can now be called without arguments, with UUID or or we can call with nil - this keeps the default value for internal view
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()  // if fails to load, create new instance
        // subscribing to Publisher, links this subscriber to thie View Model
        autosaveCancellable = $emojiArt.sink { emojiArt in
            print("json: \(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)   // save to persistent dict
        }
        fetchBackgroundImageData()
    }
    
    var url: URL? { didSet { self.save(self.emojiArt) } }   // autosave url
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.emojiArt = EmojiArt(json: try? Data(contentsOf: url)) ?? EmojiArt()
        fetchBackgroundImageData()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            self.save(emojiArt)
        }
    }
    
    // write to filesystem url
    private func save(_ emojiArt: EmojiArt) {
        if url != nil {
            try? emojiArt.json?.write(to: url!)
        }
        
    }
    
    // read only version of emojiArt
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            print("setting background url...")
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        print("fetch image from url...")
        backgroundImage = nil   // to show that the app has responded to the drop
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()     // cancel prev request before fetching new image
            // use Publisher to use URLSession - which is more configurable than using Data(contentsOf: item)
            let session = URLSession.shared // shared url session that whole app can use
            let publisher = session.dataTaskPublisher(for: url)     // gives us a publisher for this url session which returns a tuple
                .map { data, urlResponse in UIImage(data: data) }       // map the response of this url session
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)    // change Publisher error type to nil
            fetchImageCancellable = publisher.assign(to: \.backgroundImage, on: self)   // only works when Never is the error
            
            
            /*
            // place action in background queue
            DispatchQueue.global(qos: .userInitiated).async {
                // fetch the data from the url
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // check in case the url has changed
                        if url == self.emojiArt.backgroundURL {
                            // this code that changes the UI needs to be executed on main branch
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                    
                }
                
            }
            */
        }
    }
}

// interpreting data from Model into suitable data type for View
extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
