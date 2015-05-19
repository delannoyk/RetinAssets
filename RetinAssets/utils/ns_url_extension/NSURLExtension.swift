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

    ////////////////////////////////////////////////////////////////////////////
}
