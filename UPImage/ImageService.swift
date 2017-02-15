//
//  ImageService.swift
//  U图床
//
//  Created by Pro.chen on 15/02/2017.
//  Copyright © 2017 chenxt. All rights reserved.
//

import Cocoa

class ImageService: NSObject {
    static let shared = ImageService()
    public func uploadImg(_ pboard: NSPasteboard) {
        let files: NSArray? = pboard.propertyList(forType: NSFilenamesPboardType) as? NSArray
        var data : Data?
        statusItem.button?.image = NSImage(named: "loading-\(0)")
        statusItem.button?.image?.isTemplate = true
        if let files = files {
            guard let _ = NSImage(contentsOfFile: files.firstObject as! String) else {
                return
            }
            data =   NSData(contentsOfFile: files.firstObject as! String) as Data?
        }
        else {
            guard let type = pboard.pasteboardItems?.first?.types.first else {
                return
            }
            guard ["public.tiff","public.png"].contains(type) else {
                return
            }
            data = (pboard.pasteboardItems?.first?.data(forType: type))
            guard let _ = NSImage(data: data!) else {
                return
            }
        }
        //进行格式转换
        if data?.imageFormat == .unknown {
            let imageRep = NSBitmapImageRep(data: data!)
            data = (imageRep?.representation(using: .PNG, properties: ["":""]))!
        }
        
        QNService.shared.QiniuSDKUpload(data)
        
    }

}
