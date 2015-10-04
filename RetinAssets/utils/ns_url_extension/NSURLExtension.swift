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
        return CFURLHasDirectoryPath(self as CFURL)
    }

    func childrenFileURLs() -> [NSURL] {
        if directoryURL {
            let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(self,
                includingPropertiesForKeys: nil,
                options: .SkipsHiddenFiles)

            if let contents = contents {
                return contents.reduce([]) { (list, url) -> [NSURL] in
                    return list + url.childrenFileURLs()
                }
            }
        }
        return [self]
    }

    ////////////////////////////////////////////////////////////////////////////
}
