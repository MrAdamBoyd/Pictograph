//
//  DragDropManager.swift
//  Pictograph
//
//  Created by Adam Boyd on 2017/6/9.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//
//
//import Foundation
//import UIKit
//import MobileCoreServices
//
//class DragDropManager: NSObject, UIDragInteractionDelegate, UIDropInteractionDelegate {
//    
//    weak var imageView: UIImageView?
//    weak var view: UIView?
//    
//    init(imageView: UIImageView, in view: UIView) {
//        super.init()
//        
//        self.imageView = imageView
//        self.view = view
//    }
//    
//    // MARK: Dropping
//    
//    //Saying "yes, we can handle images"
//    @available(iOS 11.0, *)
//    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
//        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
//    }
//    
//    //User moving the image over, saying we want to copy it if the image is dragged within the imageview
//    @available(iOS 11.0, *)
//    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
//        let dropLocation = session.location(in: self.view)
//        let operation: UIDropOperation
//        
//        if self.imageView?.frame.contains(dropLocation) ?? false {
//            operation = .copy
//        } else {
//            operation = .cancel
//        }
//        
//        return UIDropProposal(operation: operation)
//    }
//    
//    //Actually performing the drop
//    @available(iOS 11.0, *)
//    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        //Consume the drag items
//        session.loadObjects(ofClass: UIImage.self) { imageItems in
//            guard let images = imageItems as? [UIImage], let firstImage = images.first else { return }
//            self.imageView?.image = firstImage
//        }
//    }
//    
//    // MARK: Dragging
//    
//    //Dragging the image of the image view out of the app
//    @available(iOS 11.0, *)
//    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
//        guard let image = self.imageView?.image else { return [] }
//        let provider = NSItemProvider(object: image)
//        let item = UIDragItem(itemProvider: provider)
//        return [item]
//    }
//}
