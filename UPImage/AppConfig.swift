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
    var linkType : LinkType = .url //链接模式
    var autoUp : Bool = false //是否自动上传
    var useDefServer : Bool = true //是否配置好 ， true 未配置， false 已配置
 
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(linkType.rawValue.description, forKey: "linkType")
        aCoder.encode(autoUp.hashValue.description, forKey: "autoUp")
        aCoder.encode(useDefServer.hashValue.description, forKey: "useDefServer")
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard  let _ = aDecoder.decodeObject(forKey: "linkType") else {
            return nil
        }
        autoUp = Bool(NSNumber(value: Int(aDecoder.decodeObject(forKey: "autoUp") as! String)!))
        linkType = LinkType(rawValue: Int(aDecoder.decodeObject(forKey: "linkType") as! String)! )!
        useDefServer = Bool(NSNumber(value: Int(aDecoder.decodeObject(forKey: "useDefServer") as! String)!))
        super.init()
    }
    override init() {
        super.init();
        setInCache("appConfig");
    }
}
