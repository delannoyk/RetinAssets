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
        if let url = NSURL(fileURLWithPath: filepath),
            ext = url.pathExtension where contains(supportedExtensions, ext) {
                fileURL = url
        }
        else {
            return nil
        }
    }

    init?(fileURL: NSURL) {
        if let ext = fileURL.pathExtension where contains(supportedExtensions, ext) {
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
        if let url = NSURL(fileURLWithPath: path) {
            return fromDirectoryAtURL(url)
        }
        return nil
    }

    static func fromDirectoryAtURL(url: NSURL) -> [Image]? {
        return compact(url.childrenFileURLs().map { Image(fileURL: $0) })
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Resizing
    ////////////////////////////////////////////////////////////////////////////

    func resizeAtScale(factor: CGFloat) -> NSData? {
        if let src = NSImage(contentsOfURL: fileURL),
            representation = src.representations.first as? NSImageRep {
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
                    src.drawInRect(NSRect(origin: .zeroPoint, size: newSize), fromRect: .zeroRect, operation: .CompositeCopy, fraction: 1)
                    NSGraphicsContext.restoreGraphicsState()

                    return bitmap.representationUsingType(.NSPNGFileType, properties: [:])
                }
        }
        return nil
    }

    ////////////////////////////////////////////////////////////////////////////
}
