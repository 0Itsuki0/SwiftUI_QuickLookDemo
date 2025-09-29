//
//  ContentView.swift
//  QuickLookDemo
//
//  Created by Itsuki on 2025/09/28.
//

import SwiftUI
import QuickLook


class ThumbnailGenerator {
    static func generate(fileURL: URL, size: CGSize, scale: CGFloat) async throws -> Image {
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: size, scale: scale, representationTypes: .all)
        let representation: QLThumbnailRepresentation = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        return Image(uiImage: representation.uiImage)
    }
}


struct ContentView: View {
    @State private var url: URL? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("""
                A demo of using quick look framework to 
                
                - preview/edit files in app
                - generate thumbnails
                
                * For both common file types as well as custom file types.

                """)
                .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    
                    VStack {
                        Text("Common File Types")
                            .font(.headline)
                        
                        Text("Microsoft Offices, Images, and etc")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink(destination: {
                        QuickLookSingle()
                            .navigationTitle("Preview/Edit Single File")
                            .navigationBarTitleDisplayMode(.large)
                    }, label: {
                        Text("Single File")
                    })
                    
                    NavigationLink(destination: {
                        QuickLookMultiple()
                            .navigationTitle("Preview/Edit Multiple")
                            .navigationBarTitleDisplayMode(.large)

                    }, label: {
                        Text("Multiple Files")
                    })
                    
                    NavigationLink(destination: {
                        QuickLookWithThumbnail()
                            .navigationTitle("With Thumbnail For File")
                            .navigationBarTitleDisplayMode(.large)

                    }, label: {
                        Text("With Thumbnail")
                    })
                }
                
                Divider()
                
                VStack(spacing: 16) {
                    VStack {
                        Text("Custom File Types")
                            .font(.headline)
                        
                        Text("File Types exported by the App")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    
                    NavigationLink(destination: {
                        QuickLookCustomFileType()
                            .navigationTitle("Preview Custom File Type")
                            .navigationBarTitleDisplayMode(.large)

                    }, label: {
                        Text("Preview")
                    })
                    
                    NavigationLink(destination: {
                        QuickLookCustomFileTypeWithThumbnail()
                            .navigationTitle("Thumbnail For Custom")
                            .navigationBarTitleDisplayMode(.large)

                    }, label: {
                        Text("With Thumbnail")
                    })
                }
                
            }
            .padding(.all, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.yellow.opacity(0.1))
            .navigationTitle("QuickLook Demo")
            .navigationBarTitleDisplayMode(.large)
            
        }
        
    }
}



private struct QuickLookMultiple: View {
    @State private var url: URL? = nil

    private let urls: [URL] = (1..<4).map({ index in
        Bundle.main.url(forResource: "pikachu\(index)", withExtension: "jpg")
    }).filter({$0 != nil}).map({$0!})

    var body: some View {
        VStack(spacing: 16) {
            ForEach(urls, id: \.self) { url in
                Button(action: {
                    self.url = url
                }, label: {
                    Text(url.lastPathComponent)
                })
                .buttonStyle(.glassProminent)
            }
            .quickLookPreview($url, in: urls)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))

    }
}

private struct QuickLookSingle: View {
    @State private var url: URL? = nil

    var body: some View {
        Button(action: {
            self.url = Bundle.main.url(forResource: "pikachu1", withExtension: "jpg")

        }, label: {
            Text("Preview")
        })
        .buttonStyle(.glassProminent)
        .quickLookPreview($url)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))
    }
}


private struct QuickLookWithThumbnail: View {
    @Environment(\.displayScale) private var scale

    @State private var url: URL? = nil
    @State private var thumbnail: Image? = nil
    
    private let fileURL = Bundle.main.url(forResource: "pikachu1", withExtension: "jpg")
    private let thumbnailSize: CGSize = .init(width: 240, height: 320)
    
    var body: some View {
        Button(action: {
            self.url = fileURL
        }, label: {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            } else {
                Text("Preview")
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))
        .quickLookPreview($url)
        .task {
            guard let url = self.fileURL else {
                return
            }
            self.thumbnail = try? await self.generateBestThumbnail(fileURL: url, size: self.thumbnailSize, scale: self.scale)
            
            // for creating a file icon or low-quality thumbnail quickly, and replacing it with a higher quality thumbnail once it's available, uncomment the following
            // generateThumbnails(fileURL: url, size: self.thumbnailSize, scale: self.scale)
        }

    }
    
    // create the best possible thumbnail
    private func generateBestThumbnail(fileURL: URL, size: CGSize, scale: CGFloat) async throws -> Image {
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: size, scale: scale, representationTypes: .all)
        let representation: QLThumbnailRepresentation = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        return Image(uiImage: representation.uiImage)
    }
    
    
    // to create a file icon or low-quality thumbnail quickly,
    // and replace it with a higher quality thumbnail once it's available.
    private func generateThumbnails(fileURL: URL, size: CGSize, scale: CGFloat) {
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: size, scale: scale, representationTypes: .all)
        QLThumbnailGenerator.shared.generateRepresentations(for: request, update: { representation, type, error in
            if let representation {
                self.thumbnail = Image(uiImage: representation.uiImage)
            }
        })
    }
}



private struct QuickLookCustomFileType: View {
    @State private var url: URL? = nil

    var body: some View {
        Button(action: {
            self.url = Bundle.main.url(forResource: "ItsukiFileTypeDemo", withExtension: "itsuki")

        }, label: {
            Text("Preview")
        })
        .buttonStyle(.glassProminent)
        .quickLookPreview($url)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))

    }
}



private struct QuickLookCustomFileTypeWithThumbnail: View {
    @Environment(\.displayScale) private var scale

    @State private var url: URL? = nil
    @State private var thumbnail: Image? = nil
    
    private let fileURL = Bundle.main.url(forResource: "ItsukiFileTypeDemo", withExtension: "itsuki")
    private let thumbnailSize: CGSize = .init(width: 240, height: 320)
    
    var body: some View {
        Button(action: {
            self.url = fileURL
        }, label: {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            } else {
                Text("Preview")
            }
        })
        .quickLookPreview($url)
        .task {
            guard let url = self.fileURL else {
                return
            }
            self.thumbnail = try? await self.generateThumbnail(fileURL: url, size: self.thumbnailSize, scale: self.scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))


    }
    
    private func generateThumbnail(fileURL: URL, size: CGSize, scale: CGFloat) async throws -> Image {
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: size, scale: scale, representationTypes: .all)
        let representation: QLThumbnailRepresentation = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        return Image(uiImage: representation.uiImage)
    }
}

#Preview {
    ContentView()
}
