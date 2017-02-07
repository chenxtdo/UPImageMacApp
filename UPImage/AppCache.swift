//
//  AppCache.swift
//  U图床
//
//  Created by Pro.chen on 27/12/2016.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Foundation
import TMCache

protocol DiskCache {
//    func setInCache(_ key:String)
//    func getInCahce(_ key:String)->Self
}
extension DiskCache where Self : NSCoding{
    func setInCache(_ key:String){
        TMCache.shared().setObject(self, forKey: key);
    }
    static func getInCahce(_ key:String)->Self?{
        return  TMCache.shared().object(forKey: key) as? Self;
    }
}

class AppCache: NSObject{
    static let shared = AppCache()
    var imagesCacheArr: [[String: AnyObject]] = Array()
    var appConfig : AppConfig!
    var qnConfig : QNConfig!
    fileprivate override init() {
        super.init()
        if let ac =  AppConfig.getInCahce("appConfig") {
            appConfig = ac;
        }else{
            appConfig = AppConfig();
        }
        
        if appConfig.useDefServer {
            qnConfig = nil;
        }
        else {
            qnConfig = QNConfig.getInCahce("QN_Use_Config")
        }
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
