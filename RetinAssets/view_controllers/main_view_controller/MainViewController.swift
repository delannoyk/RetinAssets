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

    @IBAction func buttonAddImagesPressed(AnyObject) {
        self.displayOpenPanel()
    }

    @IBAction func clickGestureRecognizedOnDroppableView(AnyObject) {
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
                if let URLs = panel.URLs as? [NSURL] {
                    self.convertURLs(URLs)
                }
            }
        })
    }

    func convertURLs(URLs: [NSURL]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let converted = resizeImages(atURLs: URLs, overwrite: (self.buttonOverwrite.state == NSOnState))

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = NSAlert()
                alert.alertStyle = .InformationalAlertStyle
                alert.messageText = {
                    var str = ""
                    if converted.count > 0 {
                        for convertedFile in converted {
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

    func convertFiles(files: [String]) {
        let urls = map(files, { (element) -> NSURL? in
            return NSURL(fileURLWithPath: element)
        }).reduce([], combine: { (list, object) -> [NSURL] in
            if let object = object {
                return list + [object]
            }
            return list
        })

        self.convertURLs(urls)
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - NSOpenSavePanelDelegate
    ////////////////////////////////////////////////////////////////////////////

    func panel(sender: AnyObject, shouldEnableURL url: NSURL) -> Bool {
        return (url.directoryURL || url.scaleFromImageURL() != nil)
    }

    ////////////////////////////////////////////////////////////////////////////
}
