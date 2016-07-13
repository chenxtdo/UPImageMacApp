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

