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


public enum Result<Value> {
    case success(Value)
    case failure(Value)
    
    public func Success( success: (_ value: Value) -> Void) -> Result<Value> {
        switch self {
        case .success(let value):
            success(value)
        default:
            break
        }
        
        return self
    }
    
    public func Failure( failure: (_ error: Value) -> Void) -> Result<Value> {
        switch self {
        case .failure(let error):
            failure(error)
        default:
            break
        }
        return self
    }
    
}

extension NSImage {
	
	func scalingImage() {
		let sW = self.size.width
		let sH = self.size.height
		let nW: CGFloat = 100
		let nH = nW * sH / sW
		self.size = CGSize(width: nW, height: nH)
	}
	
}



func NotificationMessage(_ message: String, informative: String? = nil, isSuccess: Bool = false) {
    
    let notification = NSUserNotification()
    let notificationCenter = NSUserNotificationCenter.default
    notificationCenter.delegate = appDelegate as? NSUserNotificationCenterDelegate
    notification.title = message
    notification.informativeText = informative
    if isSuccess {
        notification.contentImage = NSImage(named: "success")
        notification.informativeText = "链接已经保存在剪贴板里，可以直接粘贴"
    } else {
        notification.contentImage = NSImage(named: "Failure")
    }
    
    notification.soundName = NSUserNotificationDefaultSoundName;
    notificationCenter.scheduleNotification(notification)
    
}


func getDateString() -> String {
	let dateformatter = DateFormatter()
	dateformatter.dateFormat = "YYYYMMdd"
	let dataString = dateformatter.string(from: Date(timeInterval: 0, since: Date()))
	return dataString
}

func checkImageFile(_ pboard: NSPasteboard) -> Bool {
    
    let files: NSArray = pboard.propertyList(forType: NSFilenamesPboardType) as! NSArray
    let image = NSImage(contentsOfFile: files.firstObject as! String)
    guard let _ = image else {
        return false
    }
    return true
}

func getImageType(_ data: Data) -> String {
    var c: uint8 = 0
    data.copyBytes(to: &c, count: 1)
    switch c {
    case 0xFF:
        return ".jpeg"
    case 0x89:
        return ".png"
    case 0x49:
        return ".tiff"
    case 0x4D:
        return ".tiff"
    case 0x52:
        guard data.count > 12, let str = String(data: data.subdata(in: 0..<13), encoding: .ascii), str.hasPrefix("RIFF"), str.hasPrefix("WEBP") else {
            return ""
        }
        return ".webp"
    default:
        return ""
    }
}
