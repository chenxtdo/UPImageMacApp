//
//  AppCache.swift
//  U图床
//
//  Created by Pro.chen on 27/12/2016.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Foundation
import TMCache

class AppCache: NSObject{
    
    static let shared = AppCache()
    public var linkType : LinkType {
            get {
                if let linkType = UserDefaults.standard.value(forKey: "linkType") as? Int {
                    print(linkType)
                    return LinkType(rawValue: linkType)!
                }
                return .markdown
            }
            set {
                print(newValue.rawValue)
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "linkType")
            }
    }
    
    var autoUp: Bool {
        get {
            if let autoUp = UserDefaults.standard.value(forKey: "autoUp") {
                return autoUp as! Bool
            }
            return false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "autoUp")
        }
    }
    fileprivate var QN_Use_Config : [String:String]?
    fileprivate let QN_Def_Config = ["picUrlPrefix" : "http://7xqmjb.com1.z0.glb.clouddn.com/",
                                     "accessKey" :"bCsVdizvx9fPFfkh9kYi_7PreydtorjvK2lddieO",
                                     "scope":"photos",
                                     "secretKey":"Ldso9d43oRq7rKvbM78DA9YsCajO-KWsVw9FS0db"];
    
    
    
    fileprivate override init() {super.init()}
    
    
    public func getQNConfig()->[String:String]{
        
        if ImageServer.shared.useDefServer {
            return QN_Def_Config
        }
        
        if let QN_Config = QN_Use_Config {
            return  QN_Config
        }else{
            let QN_Config = TMCache.shared().object(forKey: "QN_Use_Config")
            if let obj = QN_Config as? [String:String] {
                return obj
            }
        }
        return QN_Def_Config
    }
    public func getQNUseConfig()->[String:String]?{
        if let QN_Config = QN_Use_Config {
            return  QN_Config
        }else{
            let QN_Config = TMCache.shared().object(forKey: "QN_Use_Config")
            if let obj = QN_Config as? [String:String] {
                return obj
            }
        }
        return nil
    }
    
    public func setQNConfig(configDic : [String:String]){
        TMCache.shared().setObject(configDic as NSCoding! , forKey: "QN_Use_Config")
    }

    
    func adduploadImageToCache(_ dic: [String: AnyObject]) {
        if imagesCacheArr.count < 5 {
            imagesCacheArr.append(dic)
            TMCache.shared().setObject(imagesCacheArr as NSCoding!, forKey: "imageCache")
        } else {
            imagesCacheArr.remove(at: 0)
            imagesCacheArr.append(dic)
            TMCache.shared().setObject(imagesCacheArr as NSCoding!, forKey: "imageCache")
        }
    }

    

    
    
}
