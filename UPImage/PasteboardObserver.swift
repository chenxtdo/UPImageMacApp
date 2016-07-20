//
//  PasteboardObserver.swift
//  U图床
//
//  Created by Pro.chen on 7/20/16.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Cocoa

@objc protocol PasteboardObserverSubscriber: NSObjectProtocol {
	
	func pasteboardChanged(pasteboard: NSPasteboard)
	
}

enum PasteboardObserverState {
	case Disabled
	case Enabled
	case Paused
}

class PasteboardObserver: NSObject {
	var pasteboard: NSPasteboard = NSPasteboard.generalPasteboard()
	
	var subscribers: NSMutableSet = NSMutableSet()
	var serialQueue: dispatch_queue_t = dispatch_queue_create("org.okolodev.PrettyPasteboard", DISPATCH_QUEUE_SERIAL)
	var changeCount: Int = -1
	var state: PasteboardObserverState = PasteboardObserverState.Disabled
	
	override init() {
		super.init()
	}
	
	deinit {
		self.stopObserving()
		self.removeSubscribers()
	}
	
	// Observing
	
	func startObserving() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			self.changeState(PasteboardObserverState.Enabled)
			self.observerLoop()
		});
	}
	
	func stopObserving() {
		self.changeState(PasteboardObserverState.Disabled)
	}
	
	func pauseObserving() {
		self.changeState(PasteboardObserverState.Paused)
	}
	
	func continueObserving() {
		if (self.state == PasteboardObserverState.Paused) {
			self.changeCount = self.pasteboard.changeCount;
			self.state = PasteboardObserverState.Enabled
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
		for anySubscriber: AnyObject in self.subscribers {
			if let subscriber = anySubscriber as? protocol<PasteboardObserverSubscriber> {
				subscriber.pasteboardChanged(self.pasteboard)
			}
		}
		self.continueObserving()
	}
	
	func changeState(newState: PasteboardObserverState) {
		dispatch_sync(self.serialQueue, { () -> Void in
			self.state = newState;
		});
	}
	
	func isEnabled() -> Bool {
		return self.state == PasteboardObserverState.Enabled;
	}
	
	// Subscribers
	
	func addSubscriber(subscriber: PasteboardObserverSubscriber) {
		self.subscribers.addObject(subscriber)
	}
	
	func removeSubscribers() {
		self.subscribers.removeAllObjects()
	}
}
