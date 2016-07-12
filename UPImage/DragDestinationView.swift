//
//  DragDestinationView.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/9.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa

class DragDestinationView: NSView {
	
	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect)
		
		// Drawing code here.
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		// 注册接受文件拖入的类型
		registerForDraggedTypes([NSFilenamesPboardType])
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
		let pboard = sender.draggingPasteboard()
		
		if checkImageFile(pboard) {
			return NSDragOperation.Copy
		} else {
			return NSDragOperation.None
		}
	}
	
	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		let pboard = sender.draggingPasteboard()
		return checkImageFile(pboard)
	}
	
	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		let pboard = sender.draggingPasteboard()
		QiniuUpload(pboard)
		return true
	}
}
