//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 9/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI

// View Model
class EmojiArtDocument: ObservableObject {
    
    static let palette: String = "👙🌂👑👘👔👠"
    @Published private(set) var backgroundImage: UIImage?
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
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
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil   // to show that the app has responded to the drop
        if let url = self.emojiArt.backgroundURL {
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
            
        }
    }
}

// interpreting data from Model into suitable data type for View
extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
