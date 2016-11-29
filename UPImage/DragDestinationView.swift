//
//  DragDestinationView.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/9.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa

class DragDestinationView: NSView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		// Drawing code here.
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		// 注册接受文件拖入的类型
		register(forDraggedTypes: [NSFilenamesPboardType])
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		let pboard = sender.draggingPasteboard()
		
		if checkImageFile(pboard) {
			statusItem.button?.image = NSImage(named: "upload")
			statusItem.button?.image?.isTemplate = true
			
			return NSDragOperation.copy
		} else {
			return NSDragOperation()
		}
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		statusItem.button?.image = NSImage(named: "StatusIcon")
		statusItem.button?.image?.isTemplate = true
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let pboard = sender.draggingPasteboard()
		return checkImageFile(pboard)
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let pboard = sender.draggingPasteboard()
		QiniuUpload(pboard)
		return true
	}
}
