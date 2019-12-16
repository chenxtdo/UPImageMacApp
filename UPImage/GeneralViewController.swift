//
//  GeneralViewController.swift
//  U图床
//
//  Created by Pro.chen on 7/18/16.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences


class GeneralViewController: NSViewController, MASPreferencesViewController {
    var viewIdentifier: String = "general"
	var toolbarItemLabel: String? { get { return "基本" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImage.preferencesGeneralName) } }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
}
