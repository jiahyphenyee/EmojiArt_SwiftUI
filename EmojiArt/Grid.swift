//
//  Grid.swift
//  Memorize
//
//  Created by Koe Jia-Yee on 3/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI

extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView ) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}
 
// Container View
struct Grid<Item, ID, ItemView>: View where ItemView: View, ID: Hashable {
    private var items: [Item]
    private var id: KeyPath<Item, ID>
    private var viewForItem: (Item) -> ItemView
    
    init(_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.id = id
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        return GeometryReader { geometry in
            // create GridLayout based on space offered
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))   // just so that we don't need to self. so many times
        }
    }
    
    private func body (for layout: GridLayout) -> some View {
        ForEach (items, id: id) { item in
            self.body(for: item, in: layout)
        }
    }
    
    private func body (for item: Item, in layout: GridLayout) -> some View {
        let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] } )  // get index of item in items array
        return Group {
            if index != nil {
                 viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(layout.location(ofItemAt: index!))    // without the if index != nil, this will crash if index == nil
            }
        }
    }
}
