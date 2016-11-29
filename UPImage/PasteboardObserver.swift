//
//  PasteboardObserver.swift
//  U图床
//
//  Created by Pro.chen on 7/20/16.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Cocoa

@objc protocol PasteboardObserverSubscriber: NSObjectProtocol {
	
	func pasteboardChanged(_ pasteboard: NSPasteboard)
	
}

enum PasteboardObserverState {
	case disabled
	case enabled
	case paused
}

class PasteboardObserver: NSObject {
	var pasteboard: NSPasteboard = NSPasteboard.general()
	
	var subscribers: NSMutableSet = NSMutableSet()
	var serialQueue: DispatchQueue = DispatchQueue(label: "org.okolodev.PrettyPasteboard", attributes: [])
	var changeCount: Int = -1
	var state: PasteboardObserverState = PasteboardObserverState.disabled
	
	override init() {
		super.init()
	}
	
	deinit {
		self.stopObserving()
		self.removeSubscribers()
	}
	
	// Observing
	
	func startObserving() {
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
			self.changeState(PasteboardObserverState.enabled)
			self.observerLoop()
		});
	}
	
	func stopObserving() {
		self.changeState(PasteboardObserverState.disabled)
	}
	
	func pauseObserving() {
		self.changeState(PasteboardObserverState.paused)
	}
	
	func continueObserving() {
		if (self.state == PasteboardObserverState.paused) {
			self.changeCount = self.pasteboard.changeCount;
			self.state = PasteboardObserverState.enabled
		}
	}
	
	func observerLoop() {
		while self.isEnabled() {
			usleep(250000)
			let countEquals = self.changeCount == self.pasteboard.changeCount
			if countEquals {
				continue
			}
			
			self.changeCount = self.pasteboard.changeCount
			self.pasteboardContentChanged()
		}
	}
	
	func pasteboardContentChanged() {
		self.pauseObserving()
		for anySubscriber in self.subscribers {
			if let subscriber = anySubscriber as? PasteboardObserverSubscriber {
				subscriber.pasteboardChanged(self.pasteboard)
			}
		}
		self.continueObserving()
	}
	
	func changeState(_ newState: PasteboardObserverState) {
		self.serialQueue.sync(execute: { () -> Void in
			self.state = newState;
		});
	}
	
	func isEnabled() -> Bool {
		return self.state == PasteboardObserverState.enabled;
	}
	
	// Subscribers
	
	func addSubscriber(_ subscriber: PasteboardObserverSubscriber) {
		self.subscribers.add(subscriber)
	}
	
	func removeSubscribers() {
		self.subscribers.removeAllObjects()
	}
}
