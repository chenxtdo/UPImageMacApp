//
//  UploadImageServer.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/9.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Foundation
import Qiniu

func arc() -> UInt32 { return arc4random() % 100000 }

func timeInterval() -> Int {
	
	return Int(Date(timeIntervalSinceNow: 0).timeIntervalSince1970)
}

var isUseSet: Bool {
	get {
		if let isUseSet = UserDefaults.standard.value(forKey: "isUseSet") {
			return isUseSet as! Bool
		}
		return false
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "isUseSet")
	}
	
}

var uploadUrl = "getToken"
var setQiniuUrl = "setQNConfig"
var picUrlPrefix = "http://7xqmjb.com1.z0.glb.clouddn.com/"

var QiniuToken: String {
	get {
		if let QiniuToken = UserDefaults.standard.value(forKey: "QiniuToken") {
			return QiniuToken as! String
		}
		return ""
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "QiniuToken")
	}
	
}

var urlPrefix: String {
	get {
		if let urlPrefix = UserDefaults.standard.value(forKey: "urlPrefix") {
			return urlPrefix as! String
		}
		return ""
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "urlPrefix")
	}
	
}

var accessKey: String {
	get {
		if let accessKey = UserDefaults.standard.value(forKey: "accessKey") {
			return accessKey as! String
		}
		return ""
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "accessKey")
	}
	
}

var secretKey: String {
	get {
		if let secretKey = UserDefaults.standard.value(forKey: "secretKey") {
			return secretKey as! String
		}
		return ""
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "secretKey")
	}
	
}

var bucket: String {
	get {
		if let bucket = UserDefaults.standard.value(forKey: "bucket") {
			return bucket as! String
		}
		return ""
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "bucket")
	}
	
}

func QiniuUpload(_ pboard: NSPasteboard) {
	
	// 是否自定义
	if isUseSet {
		GCQiniuUploadManager.sharedInstance().register(withScope: bucket, accessKey: accessKey, secretKey: secretKey)
		GCQiniuUploadManager.sharedInstance().createToken()
		QiniuToken = GCQiniuUploadManager.sharedInstance().uploadToken
		picUrlPrefix = urlPrefix
		
	} else {
		picUrlPrefix = "http://7xqmjb.com1.z0.glb.clouddn.com/"
		GCQiniuUploadManager.sharedInstance().register(withScope: "photos", accessKey: "bCsVdizvx9fPFfkh9kYi_7PreydtorjvK2lddieO", secretKey: "Ldso9d43oRq7rKvbM78DA9YsCajO-KWsVw9FS0db")
		GCQiniuUploadManager.sharedInstance().createToken()
		QiniuToken = GCQiniuUploadManager.sharedInstance().uploadToken
	}
	
	let files: NSArray? = pboard.propertyList(forType: NSFilenamesPboardType) as? NSArray
	
	if let files = files {
		statusItem.button?.image = NSImage(named: "loading-\(0)")
		statusItem.button?.image?.isTemplate = true
		
		guard let _ = NSImage(contentsOfFile: files.firstObject as! String) else {
			return
		}
		QiniuSDKUpload(files.firstObject as? String, data: nil, token: QiniuToken)
	}
	
	guard let data = pboard.pasteboardItems?.first?.data(forType: "public.tiff") else {
		return
	}
	guard let _ = NSImage(data: data) else {
		return
	}
	
	statusItem.button?.image = NSImage(named: "loading-\(0)")
	statusItem.button?.image?.isTemplate = true
	
	QiniuSDKUpload(nil, data: data, token: QiniuToken)
	
}

func QiniuSDKUpload(_ filePath: String?, data: Data?, token: String) {
	let upManager = QNUploadManager()
	let opt = QNUploadOption(progressHandler: { (key, percent) in
		
		statusItem.button?.image = NSImage(named: "loading-\(Int(percent*10))")
		statusItem.button?.image?.isTemplate = true
		
	})
	
	if let filePath = filePath {
		
		let fileName = getDateString() + "\(arc())" + NSString(string: filePath).lastPathComponent
		
		upManager?.putFile(filePath, key: fileName, token: token, complete: { (info, key, resp) in
			statusItem.button?.image = NSImage(named: "StatusIcon")
			statusItem.button?.image?.isTemplate = true
			guard let _ = info, let _ = resp else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			NSPasteboard.general().clearContents()
			NSPasteboard.general()
            var s = "![" + NSString(string: filePath).lastPathComponent
            s = s + "]("
            s = s + picUrlPrefix + key! + ")";
//            let s = "![" + NSString(string: filePath).lastPathComponent + "](" + picUrlPrefix + key + ")";
			NSPasteboard.general().setString(s, forType: NSStringPboardType)
            
			NotificationMessage("上传图片成功", isSuccess: true)
			var picUrl: String!
			if linkType == 0 {
				picUrl = "![" + key! + "](" + picUrlPrefix + key! + ")"
			}
			else {
				picUrl = picUrlPrefix + key!
			}
			NSPasteboard.general().setString(picUrl, forType: NSStringPboardType)
            let cU = picUrlPrefix + key!
			
			let cacheDic: [String: AnyObject] = ["image": NSImage(contentsOfFile: filePath)!, "url": cU as! AnyObject]
			adduploadImageToCache(cacheDic)
			
			}, option: opt)
	}
	
	if let data = data {
		
		let fileName = getDateString() + "\(timeInterval())" + "\(arc()).jpg"
		
		upManager?.put(data, key: fileName, token: token, complete: { (info, key, resp) in
			
			statusItem.button?.image = NSImage(named: "StatusIcon")
			statusItem.button?.image?.isTemplate = true
			
			guard let _ = info, let _ = resp else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			NotificationMessage("上传图片成功", isSuccess: true)
			NSPasteboard.general().clearContents()
			NSPasteboard.general()
			var picUrl: String!
			if linkType == 0 {
				picUrl = "![" + key! + "](" + picUrlPrefix + key! + "?imageView2/0/format/jpg)"
			}
			else {
				picUrl = picUrlPrefix + key! + "?imageView2/0/format/jpg"
			}
			
			NSPasteboard.general().setString(picUrl, forType: NSStringPboardType)
            let cU = picUrlPrefix + key! + "?imageView2/0/format/jpg"
			
			let cacheDic: [String: AnyObject] = ["image": NSImage(data: data)!, "url": cU as AnyObject]
			adduploadImageToCache(cacheDic)
			
			}, option: opt)
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
