//
//  AppDelegate.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/10.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences
import TMCache
import Carbon

func checkImageFile(_ pboard: NSPasteboard) -> Bool {
	
	let files: NSArray = pboard.propertyList(forType: NSFilenamesPboardType) as! NSArray
	let image = NSImage(contentsOfFile: files.firstObject as! String)
	guard let _ = image else {
		return false
	}
	return true
}



var appDelegate: NSObject?

var statusItem: NSStatusItem!

var imagesCacheArr: [[String: AnyObject]] = Array()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let pasteboardObserver = PasteboardObserver()
	
	@IBOutlet weak var MarkdownItem: NSMenuItem!
	@IBOutlet weak var window: NSWindow!
	
	@IBOutlet weak var statusMenu: NSMenu!
	@IBOutlet weak var cacheImageMenu: NSMenu!
	
	@IBOutlet weak var autoUpItem: NSMenuItem!
	@IBOutlet weak var uploadMenuItem: NSMenuItem!
	
	@IBOutlet weak var cacheImageMenuItem: NSMenuItem!
	lazy var preferencesWindowController: NSWindowController = {
		let imageViewController = ImagePreferencesViewController()
		let generalViewController = GeneralViewController()
		let controllers = [generalViewController, imageViewController]
		let wc = MASPreferencesWindowController(viewControllers: controllers, title: "设置")
		imageViewController.window = wc?.window
		return wc!
	}()
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		registerHotKeys()
		
		// 重置Token
        switch AppCache.shared.linkType {
        case .markdown:
            MarkdownItem.state = 1
        case .url:
            MarkdownItem.state = 0
        }
		
		pasteboardObserver.addSubscriber(self)
		
		if AppCache.shared.autoUp {
			pasteboardObserver.startObserving()
			autoUpItem.state = 1
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(notification), name: NSNotification.Name(rawValue: "MarkdownState"), object: nil)
		
		window.center()
		appDelegate = self
		statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
		let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
		statusItem.button?.superview?.addSubview(statusBarButton, positioned: .below, relativeTo: statusItem.button)
		let iconImage = NSImage(named: "StatusIcon")
		iconImage?.isTemplate = true
		statusItem.button?.image = iconImage
		statusItem.button?.action = #selector(showMenu)
		statusItem.button?.target = self
		
	}
	
	func notification(_ notification: Notification) {
			MarkdownItem.state = Int((notification.object as AnyObject) as! NSNumber)
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func showMenu() {
		
		let pboard = NSPasteboard.general()
		let files: NSArray? = pboard.propertyList(forType: NSFilenamesPboardType) as? NSArray
		
		if let files = files {
			let i = NSImage(contentsOfFile: files.firstObject as! String)
			i?.scalingImage()
			uploadMenuItem.image = i
			
		} else {
			let i = NSImage(pasteboard: pboard)
			i?.scalingImage()
			uploadMenuItem.image = i
			
		}
		
		let object = TMCache.shared().object(forKey: "imageCache")
		if let obj = object as? [[String: AnyObject]] {
			imagesCacheArr = obj
			
		}
		cacheImageMenuItem.submenu = makeCacheImageMenu(imagesCacheArr)
		
		statusItem.popUpMenu(statusMenu)
	}
	
	@IBAction func statusMenuClicked(_ sender: NSMenuItem) {
		switch sender.tag {
			// 上传
		case 1:
			let pboard = NSPasteboard.general()
			ImageServer.shared.QiniuUpload(pboard)
			// 设置
		case 2:
			preferencesWindowController.showWindow(nil)
			preferencesWindowController.window?.center()
			NSApp.activate(ignoringOtherApps: true)
		case 3:
			// 退出
			NSApp.terminate(nil)
			
		case 4:
			NSWorkspace.shared().open(URL(string: "http://lzqup.com")!)
		case 5:
			break
			
		case 6:
            sender.state = 1 - sender.state;
            AppCache.shared.autoUp =  sender.state == 1 ? true : false
            AppCache.shared.autoUp ? pasteboardObserver.startObserving() : pasteboardObserver.stopObserving()
           
		case 7:
            sender.state = 1 - sender.state
            AppCache.shared.linkType = LinkType(rawValue: sender.state)!
            guard let imagesCache = imagesCacheArr.first else {
                return
            }
            let picUrl = imagesCache["url"] as! String
            NSPasteboard.general().setString(LinkType.getLink(path: picUrl, type: AppCache.shared.linkType), forType: NSStringPboardType)
            
		default:
			break
		}
		
	}
	
	@IBAction func btnClick(_ sender: NSButton) {
		switch sender.tag {
		case 1:
			NSWorkspace.shared().open(URL(string: "http://blog.lzqup.com/tools/2016/07/10/Tools-UPImage.html")!)
			self.window.close()
		case 2:
			self.window.close()
			
		default:
			break
		}
	}
	
	func makeCacheImageMenu(_ imagesArr: [[String: AnyObject]]) -> NSMenu {
		let menu = NSMenu()
		if imagesArr.count == 0 {
			let item = NSMenuItem(title: "没有历史", action: nil, keyEquivalent: "")
			menu.addItem(item)
		} else {
			for index in 0..<imagesArr.count {
				let item = NSMenuItem(title: "", action: #selector(cacheImageClick(_:)), keyEquivalent: "")
				item.tag = index
				let i = imagesArr[index]["image"] as? NSImage
				i?.scalingImage()
				item.image = i
				menu.insertItem(item, at: 0)
			}
		}
		
		return menu
	}
	
	func cacheImageClick(_ sender: NSMenuItem) {
		NSPasteboard.general().clearContents()
		let picUrl = imagesCacheArr[sender.tag]["url"] as! String
		NSPasteboard.general().setString(LinkType.getLink(path: picUrl, type: AppCache.shared.linkType), forType: NSStringPboardType)
		NotificationMessage("图片链接获取成功", isSuccess: true)
	}
	
}


extension AppDelegate: NSUserNotificationCenterDelegate, PasteboardObserverSubscriber {
	// 强行通知
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		return true
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		
		
	}
	
	func pasteboardChanged(_ pasteboard: NSPasteboard) {
		ImageServer.shared.QiniuUpload(pasteboard)
		
	}
	
	func registerHotKeys() {
		
		var gMyHotKeyRef: EventHotKeyRef? = nil
		var gMyHotKeyIDU = EventHotKeyID()
		var gMyHotKeyIDM = EventHotKeyID()
		var eventType = EventTypeSpec()
		
		eventType.eventClass = OSType(kEventClassKeyboard)
		eventType.eventKind = OSType(kEventHotKeyPressed)
		gMyHotKeyIDU.signature = OSType(32)
		gMyHotKeyIDU.id = UInt32(kVK_ANSI_U);
		gMyHotKeyIDM.signature = OSType(46);
		gMyHotKeyIDM.id = UInt32(kVK_ANSI_M);
		
		RegisterEventHotKey(UInt32(kVK_ANSI_U), UInt32(cmdKey), gMyHotKeyIDU, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
		
		RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey), gMyHotKeyIDM, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
		
		// Install handler.
		InstallEventHandler(GetApplicationEventTarget(), { (nextHanlder, theEvent, userData) -> OSStatus in
			var hkCom = EventHotKeyID()
			GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkCom)
			switch hkCom.id {
			case UInt32(kVK_ANSI_U):
				let pboard = NSPasteboard.general()
				ImageServer.shared.QiniuUpload(pboard)
			case UInt32(kVK_ANSI_M):
                
                AppCache.shared.linkType = LinkType(rawValue: 1 - AppCache.shared.linkType.rawValue)!
                print(AppCache.shared.linkType.rawValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MarkdownState"), object:  AppCache.shared.linkType.rawValue)
                guard let imagesCache = imagesCacheArr.last else {
                    return 33
                }
                NSPasteboard.general().clearContents()
                let picUrl = imagesCache["url"] as! String
                NSPasteboard.general().setString(LinkType.getLink(path: picUrl, type: AppCache.shared.linkType), forType: NSStringPboardType)
  
                
			default:
				break
			}
			
			return 33
			/// Check that hkCom in indeed your hotkey ID and handle it.
			}, 1, &eventType, nil, nil)
		
	}
	
}

