//
//  ThumbnailProvider.swift
//  CustomQLThumbnailProvider
//
//  Created by Itsuki on 2025/09/29.
//

import UIKit
import QuickLookThumbnailing

class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        // First way: Draw the thumbnail into the current context, set up with UIKit's coordinate system.
        handler(QLThumbnailReply(contextSize: request.maximumSize, currentContextDrawing: { () -> Bool in

            let uiImage = UIImage(data: try! .init(contentsOf: Bundle.main.url(forResource: "pikachu", withExtension: "jpeg")!))!
            let size = request.maximumSize
            let renderer = UIGraphicsImageRenderer(size:size)

            let image = renderer.image { context in
            
                uiImage.draw(in: CGRect(origin: .zero, size: size))
                
                let textFontAttributes = [
                   NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                   NSAttributedString.Key.foregroundColor: UIColor.red,
                ]

                request.fileURL.lastPathComponent.draw(in: CGRect(x: 10, y: size.height - 24, width: size.width - 10, height: 24), withAttributes: textFontAttributes)
                
                let rectangle = UIBezierPath(roundedRect: CGRect(origin: .init(x: size.width - 12, y: 0), size: CGSize(width: 12, height: 12)), cornerRadius: 0)
                rectangle.stroke()
                rectangle.fill()
                
                let heart = UIImage(systemName: "heart.fill")!.withRenderingMode(.alwaysTemplate).withTintColor(.red)
                heart.draw(in: CGRect(x: size.width - 24, y: size.height - 24, width: 24, height: 24))
                
                UIColor.red.setStroke()
                context.stroke(CGRect(origin: .zero, size: size))

            }

            image.draw(at: .zero)
            
            // Return true if the thumbnail was successfully drawn inside this block.
            return true
        }), nil)
        
        /*
        
        // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
        handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { (context) -> Bool in
            // Draw the thumbnail here.
         
            // Return true if the thumbnail was successfully drawn inside this block.
            return true
        }), nil)
         
        // Third way: Set an image file URL.
        handler(QLThumbnailReply(imageFileURL: Bundle.main.url(forResource: "fileThumbnail", withExtension: "jpg")!), nil)
        
        */
    }
}
