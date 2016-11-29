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
	func resizeImage(_ width: CGFloat, _ height: CGFloat) -> NSImage {
		let img = NSImage(size: CGSize(width: width, height: height))
		img.lockFocus()
		let ctx = NSGraphicsContext.current()
		ctx?.imageInterpolation = .high
		self.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
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

func adduploadImageToCache(_ dic: [String: AnyObject]) {
	if imagesCacheArr.count < 5 {
		imagesCacheArr.append(dic)
		TMCache.shared().setObject(imagesCacheArr as NSCoding!, forKey: "imageCache")
	} else {
		imagesCacheArr.remove(at: 0)
		imagesCacheArr.append(dic)
		TMCache.shared().setObject(imagesCacheArr as NSCoding!, forKey: "imageCache")
	}
}

private let pngHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
private let jpgHeaderSOI: [UInt8] = [0xFF, 0xD8]
private let jpgHeaderIF: [UInt8] = [0xFF]
private let gifHeader: [UInt8] = [0x47, 0x49, 0x46]

enum ImageFormat {
	case unknown, png, jpeg, gif
}

extension Data {
	var kf_imageFormat: ImageFormat {
		var buffer = [UInt8](repeating: 0, count: 8)
		(self as NSData).getBytes(&buffer, length: 8)
		if buffer == pngHeader {
			return .png
		} else if buffer[0] == jpgHeaderSOI[0] &&
		buffer[1] == jpgHeaderSOI[1] &&
		buffer[2] == jpgHeaderIF[0]
		{
			return .jpeg
		} else if buffer[0] == gifHeader[0] &&
		buffer[1] == gifHeader[1] &&
		buffer[2] == gifHeader[2]
		{
			return .gif
		}
		
		return .unknown
	}
}

func getDateString() -> String {
	let dateformatter = DateFormatter()
	dateformatter.dateFormat = "YYYYMMdd"
	let dataString = dateformatter.string(from: Date(timeInterval: 0, since: Date()))
	return dataString
}
