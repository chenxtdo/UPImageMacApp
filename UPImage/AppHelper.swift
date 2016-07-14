//
//  AppHelper.swift
//  U图床
//
//  Created by Pro.chen on 16/7/13.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Foundation
import AppKit
import TMCache

extension NSImage {
	func resizeImage(width: CGFloat, _ height: CGFloat) -> NSImage {
		let img = NSImage(size: CGSizeMake(width, height))
		img.lockFocus()
		let ctx = NSGraphicsContext.currentContext()
		ctx?.imageInterpolation = .High
		self.drawInRect(NSMakeRect(0, 0, width, height), fromRect: NSMakeRect(0, 0, size.width, size.height), operation: .CompositeCopy, fraction: 1)
		img.unlockFocus()
		return img
	}
	
	func scalingImage() {
		let sW = self.size.width
		let sH = self.size.height
		let nW: CGFloat = 100
		let nH = nW * sH / sW
		self.size = CGSize(width: nW, height: nH)
	}
	
}

func adduploadImageToCache(dic: [String: AnyObject]) {
	if imagesCacheArr.count < 5 {
		imagesCacheArr.append(dic)
		TMCache.sharedCache().setObject(imagesCacheArr, forKey: "imageCache")
	} else {
		imagesCacheArr.removeAtIndex(0)
		imagesCacheArr.append(dic)
		TMCache.sharedCache().setObject(imagesCacheArr, forKey: "imageCache")
	}
}


private let pngHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
private let jpgHeaderSOI: [UInt8] = [0xFF, 0xD8]
private let jpgHeaderIF: [UInt8] = [0xFF]
private let gifHeader: [UInt8] = [0x47, 0x49, 0x46]

enum ImageFormat {
    case Unknown, PNG, JPEG, GIF
}

extension NSData {
    var kf_imageFormat: ImageFormat {
        var buffer = [UInt8](count: 8, repeatedValue: 0)
        self.getBytes(&buffer, length: 8)
        if buffer == pngHeader {
            return .PNG
        } else if buffer[0] == jpgHeaderSOI[0] &&
            buffer[1] == jpgHeaderSOI[1] &&
            buffer[2] == jpgHeaderIF[0]
        {
            return .JPEG
        } else if buffer[0] == gifHeader[0] &&
            buffer[1] == gifHeader[1] &&
            buffer[2] == gifHeader[2]
        {
            return .GIF
        }
        
        return .Unknown
    }
}