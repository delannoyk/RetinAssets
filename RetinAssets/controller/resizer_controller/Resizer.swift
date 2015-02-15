//
//  Resizer.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

func resizeImages(atURLs URLs: [NSURL], overwrite: Bool = true) -> [String] {
    //Searching for images in URLs (including subfolders if possible)
    let imagesURLs = reduce(URLs, [], { (list, URL) -> [NSURL] in
        //We analyze children and add images in them
        let subURLs = reduce(URL.childrenFileURLs(), [], { (sublist, subURL) -> [NSURL] in
            if let imageType = subURL.imageType() {
                //We only add URLs that points to an image
                return sublist + [subURL]
            }
            return sublist
        })
        return list + subURLs
    })

    //Conversion can begin
    var convertedFile = [String]()

    for URL in imagesURLs {
        if let originalScale = URL.scaleFromImageURL() {
            var scale = originalScale - 1
            let ext = URL.pathExtension ?? ""
            let filenameWithoutScale = (URL.lastPathComponent ?? "").stringByReplacingOccurrencesOfString("@\(originalScale)x", withString: "").stringByDeletingPathExtension

            //We generate every images for every scale
            while scale > 0 {
                let factor = CGFloat(originalScale) / CGFloat(scale)
                let newFilename = filenameWithoutScale + (scale > 1 ? "@\(scale)x" : "") + ".\(ext)"
                if let newURL = URL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent(newFilename) {
                    if overwrite || !NSFileManager.defaultManager().fileExistsAtPath(newURL.path!) {
                        NSImage.createResizedImage(imageURL: URL, atNewURL: newURL, withSizingDownFactor: factor)
                        convertedFile.append(newFilename)
                    }
                }
                scale--
            }
        }
    }

    return convertedFile
}
