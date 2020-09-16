//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Koe Jia-Yee on 9/9/20.
//  Copyright © 2020 Koe Jia-Yee. All rights reserved.
//

import SwiftUI

// View
struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)  // initialise State var
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: self.document, chosenPalette: $chosenPalette)  // binding state value passed
                ScrollView(.horizontal) {
                    HStack {
                        // for each on chars in a string
                        ForEach(chosenPalette.map {String($0)},  id:\.self) { emoji in Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            .onDrag {
                                NSItemProvider(object: emoji as NSString)
                            }
                        }
                    }
                }
//                .onAppear{ self.chosenPalette = self.document.defaultPalette }
//                .layoutPriority(1)
            }
//            .padding(.horizontal)   // default padding on left and right
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if !self.isLoading {
                        // display emojis
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    } else {
                        // developer.apple.com/design -> SF Symbols
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])  // ignore safe areas
                    // calling publisher from View Model using onReceive()
                .onReceive(self.document.$backgroundImage) { image in
                        self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)    // convert from global device coordinate system
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x/self.zoomScale, y: location.y/self.zoomScale)
                    return self.drop(providers: providers, at: location)
                } // providers: NSItemProviders provide information of drops
                .navigationBarItems(trailing: Button(action: {
                    // shared pasteboard on the device
                    if let url = UIPasteboard.general.url {
                        self.document.backgroundURL = url
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                }))
            }
        }
    }
    
    // check if background image is loading
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    // temp variable for UI only, to adjust zoom
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale = finalGestureScale
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation{
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, size.width > 0, size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = CGSize.zero     // reset to center
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
        
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
        .onEnded { finalDragGestureValue in
            self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            
        }
    }
    
//    private func font(for emoji: EmojiArt.Emoji) -> Font {
//        Font.system(size: emoji.fontSize * zoomScale)
//    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale + size.width/2, y: location.y * zoomScale + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    // returns if drop is successful, check if URL or String dropped
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        print("dropping image...")
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        
        if !found {
            found = providers.loadFirstObject(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
