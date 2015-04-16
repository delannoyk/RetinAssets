//
//  NSURLExtension.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

extension NSURL {
    // MARK: - Path
    ////////////////////////////////////////////////////////////////////////////

    var directoryURL: Bool {
        //CFURLHasDirectoryPath returns a Boolean which isn't a Bool type.
        //We have to check for true/false manually.
        return CFURLHasDirectoryPath(self as CFURL) == 1
    }

    func childrenFileURLs() -> [NSURL] {
        if self.directoryURL {
            let contents = NSFileManager.defaultManager().contentsOfDirectoryAtURL(self,
                includingPropertiesForKeys: nil,
                options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,
                error: nil)

            if let contents = contents as? [NSURL] {
                return reduce(contents, [], { (list, url) -> [NSURL] in
                    return list + url.childrenFileURLs()
                })
            }
        }
        return [self]
    }

    func scaleFromImageURL() -> Int? {
        if let imageType = self.imageType() {
            if let regex = NSRegularExpression(pattern: "@([2-9])x$", options: nil, error: nil) {
                let lastComponents = (self.absoluteString?.lastPathComponent.stringByDeletingPathExtension) ?? ""
                if let match = regex.firstMatchInString(lastComponents, options: nil, range: NSMakeRange(0, count(lastComponents.utf16))) {
                    let scaleString = NSString(string: lastComponents).substringWithRange(match.rangeAtIndex(1))
                    return scaleString.toInt()
                }
            }
        }
        return nil
    }

    func imageType() -> NSBitmapImageFileType? {
        if let ext = self.pathExtension?.lowercaseString {
            if ext == "jpg" || ext == "jpeg" {
                return .NSJPEGFileType
            }
            if ext == "png" {
                return .NSPNGFileType
            }
            if ext == "gif" {
                return .NSGIFFileType
            }
            if ext == "tif" || ext == "tiff" {
                return .NSTIFFFileType
            }
        }
        return nil
    }

    ////////////////////////////////////////////////////////////////////////////
}
