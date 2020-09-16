//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 16/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI

// View for list of documents
struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    // our items are navigatable to another view
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                    ) {
                        Text(self.store.name(for: document))
                    }
                }
                
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(leading: Button(action: {
                self.store.addDocument()
            }, label: {
                Image(systemName: "plus").imageScale(.large)
            }))
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
