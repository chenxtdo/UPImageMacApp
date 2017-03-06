//
//  SMMSService.swift
//  PicU
//
//  Created by Pro.chen on 26/02/2017.
//  Copyright © 2017 chenxt. All rights reserved.
//

import Cocoa
import AFNetworking
import Alamofire

class SMMSService: NSObject {
    static let shared = SMMSService()
    let api = "https://sm.ms/api/upload";
    
    
    func uploadImage(_ data: Data){
        
        var type = "";
        switch data.imageFormat {
        case .gif:
            type = "image/gif"
        case .jpeg:
            type = "image/jpeg"
        case .png:
            type = "image/png"
        case .unknown:
            type = "image/jpeg"

        }
        
        let fileName = getDateString() + "\(timeInterval())" + "\(arc())" + data.imageFormat.rawValue
        
        let manager = AFHTTPSessionManager();
        
        manager.post(api, parameters: nil, constructingBodyWith: { (formData) in
            formData.appendPart(withFileData: data, name: "smfile", fileName: fileName, mimeType: type)
        }, progress: { (progress) in
            statusItem.button?.image = NSImage(named: "loading-\(Int(progress.fractionCompleted*10))")
            statusItem.button?.image?.isTemplate = true
        }, success: { (URLSessionDataTask, responseObject) in
            statusItem.button?.image = NSImage(named: "StatusIcon")
            statusItem.button?.image?.isTemplate = true
            let re = responseObject as! [String:AnyObject];
            guard let url = re["data"]!.value(forKey: "url") as? String else{
                return
            }
            NotificationMessage("上传图片成功", isSuccess: true)
            NSPasteboard.general().clearContents()
            NSPasteboard.general()
            let picUrl = url;
            let picUrlS  = LinkType.getLink(path:picUrl,type:AppCache.shared.appConfig.linkType);
            NSPasteboard.general().setString(picUrlS, forType: NSStringPboardType)
            let cacheDic: [String: AnyObject] = ["image": NSImage(data: data)!, "url": picUrl as AnyObject]
            AppCache.shared.adduploadImageToCache(cacheDic)
        }) { (URLSessionDataTask, error) in
            statusItem.button?.image = NSImage(named: "StatusIcon")
            statusItem.button?.image?.isTemplate = true
            print(error);
        }
        
    }
    

}
