//
//  UploadImageServer.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/9.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Foundation
import Qiniu
import Alamofire

func arc() -> UInt32 { return arc4random() % 100000 }

func timeInterval() -> Int {
	
	return Int(NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970)
}

//var pathURL = "http://7xqmjb.com1.z0.glb.clouddn.com/"
var isUseSet: Bool {
	get {
		if let isUseSet = NSUserDefaults.standardUserDefaults().valueForKey("isUseSet") {
			return isUseSet as! Bool
		}
		return false
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "isUseSet")
	}
	
}

var uploadUrl = "getToken.php"
var setQiniuUrl = "setQiniuInfo.php"
var picUrlPrefix = "http://7xqmjb.com1.z0.glb.clouddn.com/"

var QiniuToken: String {
	get {
		if let QiniuToken = NSUserDefaults.standardUserDefaults().valueForKey("QiniuToken") {
			return QiniuToken as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "QiniuToken")
	}
	
}

var UUID: String {
	get {
		if let UUID = NSUserDefaults.standardUserDefaults().valueForKey("UUID") {
			return UUID as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "UUID")
	}
	
}

var urlPrefix: String {
	get {
		if let urlPrefix = NSUserDefaults.standardUserDefaults().valueForKey("urlPrefix") {
			return urlPrefix as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "urlPrefix")
	}
	
}

var accessKey: String {
	get {
		if let accessKey = NSUserDefaults.standardUserDefaults().valueForKey("accessKey") {
			return accessKey as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "accessKey")
	}
	
}

var secretKey: String {
	get {
		if let secretKey = NSUserDefaults.standardUserDefaults().valueForKey("secretKey") {
			return secretKey as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "secretKey")
	}
	
}

var bucket: String {
	get {
		if let bucket = NSUserDefaults.standardUserDefaults().valueForKey("bucket") {
			return bucket as! String
		}
		return ""
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "bucket")
	}
	
}

func QiniuUpload(pboard: NSPasteboard) {
	
	var param: [String: AnyObject]?
	
	if isUseSet {
		param = ["id": UUID]
		picUrlPrefix = urlPrefix
		
	} else {
		picUrlPrefix = "http://7xqmjb.com1.z0.glb.clouddn.com/"
		param = nil
	}
	
	let files: NSArray? = pboard.propertyListForType(NSFilenamesPboardType) as? NSArray
	
	if let files = files {
		guard let _ = NSImage(contentsOfFile: files.firstObject as! String) else {
			return
		}
		
		if QiniuToken != "" {
			
			QiniuSDKUpload(files.firstObject as? String, data: nil, token: QiniuToken)
		} else {
			HttpRequest(Resource(path: uploadUrl, method: .GET, param: param, headers: nil), completion: { (result) in
				result.failure({ (error) in
					NotificationMessage("服务器炸了", informative: "我会尽快修复，请通过email: chenxtdo@gmail.com  联系我")
					return
				})
					.success({ (value) in
						guard let token = value.valueForKeyPath("data")?.valueForKeyPath("token") as? String else {
							return
						}
						
						QiniuToken = token
						
						QiniuSDKUpload(files.firstObject as? String, data: nil, token: token)
				})
			})
		}
		
	}
	
	guard let data = pboard.pasteboardItems?.first?.dataForType("public.tiff") else {
		return
	}
	guard let _ = NSImage(data: data) else {
		return
	}
	
	if QiniuToken != "" {
		
		QiniuSDKUpload(nil, data: data, token: QiniuToken)
		
	} else {
		
		HttpRequest(Resource(path: uploadUrl, method: .GET, param: param, headers: nil), completion: { (result) in
			result.failure({ (error) in
				NotificationMessage("服务器炸了", informative: "我会尽快修复，请通过email: chenxtdo@gmail.com  联系我")
				
				return
			})
				.success({ (value) in
					guard let token = value.valueForKeyPath("data")?.valueForKeyPath("token") as? String else {
						return
					}
					QiniuToken = token
					QiniuSDKUpload(nil, data: data, token: token)
			})
		})
	}
	
}

func QiniuSDKUpload(filePath: String?, data: NSData?, token: String) {
	let upManager = QNUploadManager()
	
	if let filePath = filePath {
		
		let fileName = "\(arc())" + NSString(string: filePath).lastPathComponent
		
		upManager.putFile(filePath, key: fileName, token: token, complete: { (info, key, resp) in
			guard let _ = info else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			guard let _ = resp else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			NSPasteboard.generalPasteboard().clearContents()
			NSPasteboard.generalPasteboard()
			NSPasteboard.generalPasteboard().setString("![" + NSString(string: filePath).lastPathComponent + "](" + picUrlPrefix + key + ")", forType: NSStringPboardType)
			NotificationMessage("上传图片成功", isSuccess: true)
			}, option: nil)
	}
	
	if let data = data {
		
		let fileName = "\(timeInterval())" + "\(arc()).png"
		
		upManager.putData(data, key: fileName, token: token, complete: { (info, key, resp) in
			guard let _ = info else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			guard let _ = resp else {
				QiniuToken = ""
				NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
				return
			}
			NotificationMessage("上传图片成功", isSuccess: true)
			NSPasteboard.generalPasteboard().clearContents()
			NSPasteboard.generalPasteboard()
			NSPasteboard.generalPasteboard().setString("![" + key + "](" + picUrlPrefix + key + "?imageView2/0/format/png)", forType: NSStringPboardType)
			
			}, option: nil)
	}
}

func NotificationMessage(message: String, informative: String? = nil, isSuccess: Bool = false) {
	
	let notification = NSUserNotification()
	let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
	notificationCenter.delegate = appDelegate as? NSUserNotificationCenterDelegate
	notification.title = message
	notification.informativeText = informative
	if isSuccess {
		notification.contentImage = NSImage(named: "success")
	} else {
		notification.contentImage = NSImage(named: "Failure")
	}
	
	notification.soundName = NSUserNotificationDefaultSoundName;
	notificationCenter.scheduleNotification(notification)
	
}
