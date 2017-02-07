//
//  AppConfig.swift
//  U图床
//
//  Created by Pro.chen on 07/02/2017.
//  Copyright © 2017 chenxt. All rights reserved.
//

import Cocoa

enum LinkType : Int {
    case url = 0
    case markdown = 1
    static func getLink(path:String,type:LinkType) -> String{
        let name = NSString(string: path).lastPathComponent
        switch type {
        case .markdown:
            return "![" + name + "](" + path  + ")"
//            return "![" + name + "](" + path + mark + ")"
        case .url:
            return path
        }
    }
}

class AppConfig: NSObject ,NSCoding ,DiskCache{
    var linkType : LinkType
    var autoUp : Bool
    var useDefServer : Bool
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(linkType.rawValue, forKey: "linkType")
        aCoder.encode(autoUp, forKey: "autoUp")
        aCoder.encode(useDefServer, forKey: "useDefServer")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard  let _ = aDecoder.decodeObject(forKey: "linkType") else {
            return nil
        }
        autoUp = aDecoder.decodeObject(forKey: "autoUp") as! Bool
        linkType = LinkType(rawValue: aDecoder.decodeObject(forKey: "linkType") as! Int)!
        useDefServer = aDecoder.decodeObject(forKey: "useDefServer") as! Bool
        super.init()
    }
    override init() {
        
        linkType = .url;
        autoUp = false;
        useDefServer = false;
        super.init();
        setInCache("appConfig");
        
    }
}
