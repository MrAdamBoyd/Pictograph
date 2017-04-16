//
//  DragAndDropBox.swift
//  Pictograph
//
//  Created by Adam Boyd on 17/4/16.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

class DragAndDropView: NSView {
    
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]
    
    var isReceivingDrag = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = self.shouldAllowDrag(sender)
        self.isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.isReceivingDrag = false
    }
    
    //Drawing blue rectangle around box when the user is trying to drag an item
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
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
