//
//  AppDelegate.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/10.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences

func checkImageFile(pboard: NSPasteboard) -> Bool {
	
	let files: NSArray = pboard.propertyListForType(NSFilenamesPboardType) as! NSArray
	let image = NSImage(contentsOfFile: files.firstObject as! String)
	// 是否是图片
	guard let _ = image else {
		return false
	}
	return true
}

var version: Int {
	get {
		if let version = NSUserDefaults.standardUserDefaults().valueForKey("version") {
			return version as! Int
		}
		return 4
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "version")
	}
	
}

let updata = "checkVersion.php"

var appDelegate: NSObject?

var statusItem: NSStatusItem!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
//	var statusItem: NSStatusItem!
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	lazy var preferencesWindowController: NSWindowController = {
		
		let imageViewController = ImagePreferencesViewController()
		let controllers = [imageViewController]
		let wc = MASPreferencesWindowController(viewControllers: controllers, title: "设置")
		imageViewController.window = wc.window
		
		return wc
	}()
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		
		if UUID == "" {
			UUID = NSUUID().UUIDString
		}
		
		window.center()
		
		appDelegate = self
		
		statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
		let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
		statusItem.button?.superview?.addSubview(statusBarButton, positioned: .Below, relativeTo: statusItem.button)
		let iconImage = NSImage(named: "StatusIcon")
		iconImage?.template = true
		statusItem.button?.image = iconImage
		statusItem.menu = statusMenu
	}
	
	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	@IBAction func statusMenuClicked(sender: NSMenuItem) {
		switch sender.tag {
			// 上传
		case 1:
			let pboard = NSPasteboard.generalPasteboard()
			QiniuUpload(pboard)
			// 设置
		case 2:
			preferencesWindowController.showWindow(nil)
			preferencesWindowController.window?.center()
			NSApp.activateIgnoringOtherApps(true)
		case 3:
			// 退出
			NSApp.terminate(nil)
			
		case 4:
			NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://www.jianshu.com/p/66d453d99c71")!)
		case 5:
			checkVersion()
		default:
			break
		}
		
	}
	
	@IBAction func btnClick(sender: NSButton) {
		switch sender.tag {
		case 1:
			NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://www.jianshu.com/p/66d453d99c71")!)
			self.window.close()
		case 2:
			self.window.close()
			
		default:
			break
		}
	}
	func checkVersion() {
		HttpRequest(Resource(path: updata, method: .GET, param: ["version": version], headers: nil)) { (result) in
			result.failure({ (error) in
				if error.code == 110 {
					NotificationMessage("已经使用的是最新版本", informative: "更新一些实用的功能，请随时保持关注", isSuccess: true)
				}
			}).success({ [weak self](value) in
				
				self?.window.makeKeyAndOrderFront(nil)
				
				NSApp.activateIgnoringOtherApps(true)
			})
		}
	}
	
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	// 强行通知
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		return true
	}
	
}

