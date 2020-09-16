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
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    // our items are navigatable to another view
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                    ) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
                // swipe to delete
                .onDelete { indexSet in
                    // for all indices in indexSet, delete those documents
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
                
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(
                leading: Button(action: {
                self.store.addDocument()
            }, label: {
                Image(systemName: "plus").imageScale(.large)
            }),
                trailing: EditButton()
            )
                .environment(\.editMode, $editMode) // sets the environment only for the View we are calling it on
            
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
