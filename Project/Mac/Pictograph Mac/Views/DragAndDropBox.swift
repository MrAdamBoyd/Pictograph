//
//  DragAndDropBox.swift
//  Pictograph
//
//  Created by Adam Boyd on 17/4/16.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

protocol DraggingDelegate: class {
    func userDraggedFile(_ file: URL?)
}

class DragAndDropView: NSView {
    
    weak var delegate: DraggingDelegate?
    
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: NSImage.imageTypes]
    
    var isReceivingDrag = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    /// Users drag entered in view
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = self.shouldAllowDrag(sender)
        self.isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    /// User cancelled drag
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.isReceivingDrag = false
    }
    
    /// Last change to accept or reject drag
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = self.shouldAllowDrag(sender)
        return allow
    }
    
    /// Dragging operation completed
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        self.isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL], !urls.isEmpty {
            self.delegate?.userDraggedFile(urls.first)
            return true
        }
        return false
        
    }
    
    //Drawing blue rectangle around box when the user is trying to drag an item
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 5
            path.stroke()
        }
    }
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
        
    }
}
