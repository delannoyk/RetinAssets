//
//  AppDelegate.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!

    // MARK: - NSApplicationDelegate
    ////////////////////////////////////////////////////////////////////////////

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window.contentViewController = MainViewController(nibName: "MainViewController", bundle: nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    //Drag & Drop onto the app icon
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        self.application(sender, openFiles: [filename])
        return true
    }

    //Drag & Drop onto the app icon
    func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        if let filenames = filenames as? [String] {
            if let controller = self.window.contentViewController as? MainViewController {
                controller.convertFiles(filenames)
            }
            else {
                let controller = MainViewController(nibName: "MainViewController", bundle: nil)
                self.window.contentViewController = controller

                controller?.convertFiles(filenames)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}

