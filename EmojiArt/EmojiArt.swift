//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 9/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import Foundation

// Model
struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        var x: Int  // offset from center
        var y: Int  // offset from center, (0,0) in the middle
        var size: Int
//        var id = UUID()
        let id: Int     // only need the id to be unique within this struct
        
        // only can initialise an Emoji within this file
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    // failable init
    init?( json: Data? ) {
        if json != nil , let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt  // replace self
        } else {
            return nil
        }
    }
    
    init() { }

    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
