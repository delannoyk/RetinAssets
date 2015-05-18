//
//  KDEDroppableView.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 14/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

class KDEDroppableView: NSView {
    var onDrop: ([String] -> ())?

    // MARK: - Initialization
    ////////////////////////////////////////////////////////////////////////////

    convenience init() {
        self.init(frame: NSRect.zeroRect)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - Drag & Drop support
    ////////////////////////////////////////////////////////////////////////////

    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pBoard = sender.draggingPasteboard()
        if let files = pBoard.propertyListForType(NSFilenamesPboardType) as? [String] {
            self.onDrop?(files)
        }
        return true
    }

    ////////////////////////////////////////////////////////////////////////////
}
