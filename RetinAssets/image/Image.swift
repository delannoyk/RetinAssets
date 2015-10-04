//
//  Image.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 19/05/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

private let supportedExtensions = ["jpg", "jpeg", "png", "gif", "tif", "tiff"]

struct Image {
    let fileURL: NSURL

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    init?(filepath: String) {
        let url = NSURL(fileURLWithPath: filepath)
        if let ext = url.pathExtension where supportedExtensions.contains(ext) {
            fileURL = url
        }
        else {
            return nil
        }
    }

    init?(fileURL: NSURL) {
        if let ext = fileURL.pathExtension where supportedExtensions.contains(ext) {
            self.fileURL = fileURL
        }
        else {
            return nil
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Instanciation
    ////////////////////////////////////////////////////////////////////////////

    static func fromDirectoryAtPath(path: String) -> [Image]? {
        return fromDirectoryAtURL(NSURL(fileURLWithPath: path))
    }

    static func fromDirectoryAtURL(url: NSURL) -> [Image]? {
        return url.childrenFileURLs().flatMap { Image(fileURL: $0) }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Resizing
    ////////////////////////////////////////////////////////////////////////////

    func resizeAtScale(factor: CGFloat) -> NSData? {
        if let src = NSImage(contentsOfURL: fileURL), representation = src.representations.first {
            src.size = NSSize(width: representation.pixelsWide, height: representation.pixelsHigh)

            let newSize = NSSize(width: ceil(src.size.width / factor), height: ceil(src.size.height / factor))
            let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                pixelsWide: Int(newSize.width),
                pixelsHigh: Int(newSize.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSCalibratedRGBColorSpace,
                bytesPerRow: 0,
                bitsPerPixel: 0)

            if let bitmap = bitmap {
                bitmap.size = newSize

                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: bitmap))
                src.drawInRect(NSRect(origin: .zero, size: newSize), fromRect: .zero, operation: .CompositeCopy, fraction: 1)
                NSGraphicsContext.restoreGraphicsState()

                return bitmap.representationUsingType(.NSPNGFileType, properties: [:])
            }
        }
        return nil
    }

    ////////////////////////////////////////////////////////////////////////////
}
