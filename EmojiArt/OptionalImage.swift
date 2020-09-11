//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 11/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)  // force it to be non-optional
            }
        }
    }
}
