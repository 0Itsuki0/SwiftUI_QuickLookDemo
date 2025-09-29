//
//  PreviewProvider.swift
//  CustomQLPreviewProvider
//
//  Created by Itsuki on 2025/09/28.
//

import QuickLook

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let data = try Data(contentsOf: request.fileURL)
        let tempFile = FileManager.default.temporaryDirectory.appending(path: "\(request.fileURL.lastPathComponent).txt")
        try data.write(to: tempFile)
        let reply: QLPreviewReply = QLPreviewReply(fileURL: tempFile)

        // setting the stringEncoding for text and html data is optional and defaults to String.Encoding.utf8
        reply.stringEncoding = .utf8
        reply.title = request.fileURL.lastPathComponent
        
        return reply
    }

}
