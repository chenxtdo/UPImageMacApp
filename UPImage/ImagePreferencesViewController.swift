//
//  ImagePreferencesViewController.swift
//  imageUpload
//
//  Created by Pro.chen on 16/7/8.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences

class ImagePreferencesViewController: NSViewController, MASPreferencesViewController {
	
	override var identifier: String? { get { return "image" } set { super.identifier = newValue } }
	var toolbarItemLabel: String? { get { return "图床" } }
	var toolbarItemImage: NSImage? { get { return NSImage(named: NSImageNameUser) } }
	
	var window: NSWindow?
	
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var accessKeyTextField: NSTextField!
	
	@IBOutlet weak var secretKeyTextField: NSTextField!
	
	@IBOutlet weak var bucketTextField: NSTextField!
	
	@IBOutlet weak var urlPrefixTextField: NSTextField!
	
	@IBOutlet weak var checkButton: NSButton!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if isUseSet {
			statusLabel.cell?.title = "目前使用自定义图床"
			statusLabel.textColor = .magentaColor()
		} else {
			statusLabel.cell?.title = "目前使用默认图床"
			statusLabel.textColor = .redColor()
		}
		
		accessKeyTextField.cell?.title = accessKey
		secretKeyTextField.cell?.title = secretKey
		bucketTextField.cell?.title = bucket
		urlPrefixTextField.cell?.title = urlPrefix
	}
	@IBAction func setDefault(sender: AnyObject) {
		isUseSet = false
		statusLabel.cell?.title = "目前使用默认图床"
		statusLabel.textColor = .redColor()
		
	}
	
	@IBAction func setQiniuConfig(sender: AnyObject) {
		if (accessKeyTextField.cell?.title.characters.count == 0 ||
			secretKeyTextField.cell?.title.characters.count == 0 ||
			bucketTextField.cell?.title.characters.count == 0 ||
			urlPrefixTextField.cell?.title.characters.count == 0) {
				showAlert("有配置信息未填写", informative: "请仔细填写")
				return
		}
		
		urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title.stringByReplacingOccurrencesOfString(" ", withString: ""))!
		
		if !(urlPrefixTextField.cell?.title.hasPrefix("http://"))! && !(urlPrefixTextField.cell?.title.hasPrefix("https://"))! {
			urlPrefixTextField.cell?.title = "http://" + (urlPrefixTextField.cell?.title)!
		}
		
		if !(urlPrefixTextField.cell?.title.hasSuffix("/"))! {
			urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title)! + "/"
		}
		
		let ack = (accessKeyTextField.cell?.title)!
		let sek = (secretKeyTextField.cell?.title)!
		let bck = (bucketTextField.cell?.title)!
		
		GCQiniuUploadManager.sharedInstance().registerWithScope(bck, accessKey: ack, secretKey: sek)
		GCQiniuUploadManager.sharedInstance().createToken()
		let ts = "1"
		checkButton.title = "验证中"
		checkButton.enabled = false
		GCQiniuUploadManager.sharedInstance().uploadData(ts.dataUsingEncoding(NSUTF8StringEncoding), progress: { (progress) in
			
		}) { [weak self](error, string, code) in
			self?.checkButton.enabled = true
			self?.checkButton.title = "验证配置"
			if error == nil {
				self?.showAlert("验证成功", informative: "配置成功。")
				accessKey = (self?.accessKeyTextField.cell?.title)!
				secretKey = (self?.secretKeyTextField.cell?.title)!
				bucket = (self?.bucketTextField.cell?.title)!
				urlPrefix = (self?.urlPrefixTextField.cell?.title)!
				self?.statusLabel.cell?.title = "目前使用自定义图床"
				self?.statusLabel.textColor = .magentaColor()
				isUseSet = true
				
			}
			else {
				self?.showAlert("验证失败", informative: "验证失败，请仔细填写信息。")
			}
			
		}
	}
	
	func showAlert(message: String, informative: String) {
		let arlert = NSAlert()
		arlert.messageText = message
		arlert.informativeText = informative
		arlert.addButtonWithTitle("确定")
		if message == "验证成功" {
			arlert.icon = NSImage(named: "Icon_32x32")
		}
		else {
			arlert.icon = NSImage(named: "Failure")
		}
		
		arlert.beginSheetModalForWindow(self.window!, completionHandler: { (response) in
			
		})
	}
	
}
