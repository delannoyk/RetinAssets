//
//  NSImageExtension.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

extension NSImage {
    // MARK: - Resizing
    ////////////////////////////////////////////////////////////////////////////

    class func createResizedImage(#imageURL: NSURL, atNewURL newURL: NSURL, withSizingDownFactor factor: CGFloat) {
        if let source = NSImage(contentsOfURL: imageURL) {
            if let representation = source.representations.first as? NSImageRep {
                source.size = NSSize(width: representation.pixelsWide, height: representation.pixelsHigh)

                let newSize = NSSize(width: ceil(source.size.width / factor),
                    height: ceil(source.size.height / factor))

                let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                    pixelsWide: Int(newSize.width),
                    pixelsHigh: Int(newSize.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: NSCalibratedRGBColorSpace,
                    bytesPerRow: 0,
                    bitsPerPixel: 0)

                if let imageRep = imageRep {
                    imageRep.size = newSize

                    NSGraphicsContext.saveGraphicsState()
                    NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: imageRep))
                    source.drawInRect(NSRect(origin: NSZeroPoint, size: newSize), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1)
                    NSGraphicsContext.restoreGraphicsState()

                    let data = imageRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
                    data?.writeToURL(newURL, atomically: true)
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
