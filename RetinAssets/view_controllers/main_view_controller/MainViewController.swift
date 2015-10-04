//
//  MainViewController.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSOpenSavePanelDelegate {
    @IBOutlet private weak var viewDroppable: KDEDroppableView!
    @IBOutlet private weak var buttonOverwrite: NSButton!

    // MARK: - ViewController's lifecycle
    ////////////////////////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewDroppable.onDrop = {[weak self] (filenames) in
            self?.convertFiles(filenames)
            return
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - Actions
    ////////////////////////////////////////////////////////////////////////////

    @IBAction func buttonAddImagesPressed(_: AnyObject) {
        self.displayOpenPanel()
    }

    @IBAction func clickGestureRecognizedOnDroppableView(_: AnyObject) {
        self.displayOpenPanel()
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - Utils
    ////////////////////////////////////////////////////////////////////////////

    private func displayOpenPanel() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.delegate = self
        panel.canCreateDirectories = true
        panel.title = "Select @3x or @2x files"

        let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
        panel.beginSheetModalForWindow(delegate.window, completionHandler: { (buttonIndex) -> Void in
            if buttonIndex == NSModalResponseOK {
                self.convertURLs(panel.URLs)
            }
        })
    }

    func convertURLs(URLs: [NSURL]) {
        let images = URLs.flatMap { Image.fromDirectoryAtURL($0) }.flattern(identity)
        convertImages(images)
    }

    func convertFiles(files: [String]) {
        let images = files.flatMap { Image.fromDirectoryAtPath($0) }.flattern(identity)
        convertImages(images)
    }

    private func convertImages(images: [Image]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var convertedFiles = [String]()

            for image in images {
                let imageScale = image.scale

                for scale in 1..<imageScale {
                    let factor = CGFloat(imageScale) / CGFloat(scale)
                    let newFilename = image.filename + (scale > 1 ? "@\(scale)x" : "") + ".\(image.fileExtension)"

                    if let newFileURL = image.fileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent(newFilename) {
                        if self.buttonOverwrite.state == NSOnState || !NSFileManager.defaultManager().fileExistsAtPath(newFileURL.path!) {
                            if let data = image.resizeAtScale(factor) {
                                data.writeToURL(newFileURL, atomically: true)
                                convertedFiles.append(newFilename)
                            }
                        }
                    }
                }
            }

            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                let alert = NSAlert()
                alert.alertStyle = .InformationalAlertStyle
                alert.messageText = {
                    var str = ""
                    if convertedFiles.count > 0 {
                        for convertedFile in convertedFiles {
                            str = str + "File \(convertedFile) was converted\n"
                        }
                    }
                    else {
                        str = "No file converted"
                    }
                    return str
                }()
                alert.addButtonWithTitle("OK")

                let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
                alert.beginSheetModalForWindow(delegate.window, completionHandler: nil)
            })
        })
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - NSOpenSavePanelDelegate
    ////////////////////////////////////////////////////////////////////////////

    func panel(sender: AnyObject, shouldEnableURL url: NSURL) -> Bool {
        return true
    }

    ////////////////////////////////////////////////////////////////////////////
}

// MARK: Image extension
////////////////////////////////////////////////////////////////////////////

extension Image {
    var scale: Int {
        do {
            let regex = try NSRegularExpression(pattern: "@([2-9])x$", options: [])
            let component = fileURL.URLByDeletingPathExtension?.lastPathComponent ?? ""
            if let match = regex.firstMatchInString(component, options: [], range: NSMakeRange(0, component.characters.count)) {
                if let scale = Int((component as NSString).substringWithRange(match.rangeAtIndex(1))) {
                    return scale
                }
            }
        } catch { }
        return 1
    }

    var filename: String {
        let lastComponent = (fileURL.URLByDeletingPathExtension?.lastPathComponent ?? "")
        return lastComponent.stringByReplacingOccurrencesOfString("@\(scale)x", withString: "")
    }

    var fileExtension: String {
        return fileURL.pathExtension ?? ""
    }
}

////////////////////////////////////////////////////////////////////////////
