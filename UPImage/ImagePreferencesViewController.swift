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
		// Do view setup here.
	}
	@IBAction func setDefault(sender: AnyObject) {
		isUseSet = false
		statusLabel.cell?.title = "目前使用默认图床"
		statusLabel.textColor = .redColor()
		QiniuToken = ""
		
	}
	
	@IBAction func setQiniuConfig(sender: AnyObject) {
		QiniuToken = ""
		if (accessKeyTextField.cell?.title.characters.count == 0 ||
			secretKeyTextField.cell?.title.characters.count == 0 ||
			bucketTextField.cell?.title.characters.count == 0 ||
			urlPrefixTextField.cell?.title.characters.count == 0) {
				showAlert("有配置信息未填写", informative: "请仔细填写")
				return
		}
		
		let param: [String: AnyObject] = ["accessKey": (accessKeyTextField.cell?.title)!,
			"secretKey": (secretKeyTextField.cell?.title)!,
			"bucket": (bucketTextField.cell?.title)!,
			"id": UUID];
		
		HttpRequest(Resource(path: setQiniuUrl, method: .GET, param: param, headers: nil)) { [weak self](result) in
			result.failure({ (error) in
				self?.showAlert("配置失败", informative: "我会尽快修复，请通过email: chenxtdo@gmail.com  联系我")
			}).success({ (value) in
				self?.showAlert("配置成功", informative: "提示：配置成功不代表信息填写正确，请通过上传图片验证")
				self?.statusLabel.cell?.title = "目前使用自定义图床"
				self?.statusLabel.textColor = .magentaColor()
				isUseSet = true
				accessKey = (self?.accessKeyTextField.cell?.title)!
				secretKey = (self?.secretKeyTextField.cell?.title)!
				bucket = (self?.bucketTextField.cell?.title)!
				urlPrefix = (self?.urlPrefixTextField.cell?.title)!
				
			})
		}
		
	}
	
	func showAlert(message: String, informative: String) {
		let arlert = NSAlert()
		arlert.messageText = message
		arlert.informativeText = informative
		arlert.addButtonWithTitle("确定")
        arlert.icon = NSImage(named: "Icon_32x32")
		arlert.beginSheetModalForWindow(self.window!, completionHandler: { (response) in
			
		})
	}
	
}
