//
//  ImageServer.swift
//  U图床
//
//  Created by Pro.chen on 27/12/2016.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Foundation
import Qiniu


enum LinkType : Int {
    case url = 0
    case markdown = 1
    
    static func getLink(path:String,type:LinkType) -> String{
        let name = NSString(string: path).lastPathComponent
        switch type {
        case .markdown:
            return "![" + name + "](" + path + mark + ")"
//            return "![" + name + "](" + path + ")"
        case .url:
            return path
        }
    }
    
}


var picUrlPrefix : String {
    get {
        return AppCache.shared.getQNConfig()["picUrlPrefix"]!
    }
}

var mark: String {
    get {
        return AppCache.shared.getQNConfig()["mark"] ?? ""
    }
}


class ImageServer: NSObject {
    
    static let shared = ImageServer()
    fileprivate var scope : String!
    fileprivate var accessKey: String!
    fileprivate var secretKey: String!
    fileprivate var liveTime: Int!
    fileprivate var QNToken : String!
//    fileprivate let upManager = QNUploadManager()
    var upManager :QNUploadManager
    fileprivate override init() {
        upManager = ImageServer.initQNManager(AppCache.shared.QNZone)
        super.init()
    }
    
    class func initQNManager(_ zoneType : Int) -> QNUploadManager {
            let config = QNConfiguration.build({ (builder: QNConfigurationBuilder?) in
                var zone : QNZone!
                switch zoneType {
                case 1:
                    zone = QNZone.zone0() //华东
                case 2:
                    zone = QNZone.zone1() //华北
                case 3:
                    zone = QNZone.zone2() //华南
                case 4:
                    zone = QNZone.zoneNa0() //北美
                default:
                    zone = QNZone.zone0()
                }
                builder?.setZone(zone);
            })
            
            let manager = QNUploadManager(configuration: config);
            
            return manager!;
    }
    
    public func register( configDic:[String:String],liveTime:Int = 5 ){
        self.scope = configDic["scope"];
        self.accessKey = configDic["accessKey"];
        self.secretKey = configDic["secretKey"];
        self.liveTime = liveTime;
    }
    
    
    public func createToken(){
        let authInfo :[String:Any] = ["scope":scope,"deadline" : Int(Date().timeIntervalSince1970) + liveTime * 24 * 3600];
        var jsonData = Data()
        do {
            try jsonData = JSONSerialization.data(withJSONObject: authInfo, options: .prettyPrinted);
        }
        catch{
            
        }
        let encodedString = self.urlSafeBase64Encode(data: jsonData);
        let encodedSignedString = HMACSHA1(key: secretKey, text: encodedString);
        let token = accessKey + ":" + encodedSignedString + ":" + encodedString;
        QNToken = token;
       
    }
    
    fileprivate func urlSafeBase64Encode(data:Data) -> String{
        var base64 = data.base64EncodedString();
        base64 = base64.replacingOccurrences(of: "+", with: "-");
        base64 = base64.replacingOccurrences(of: "/", with: "_");
        return base64
    }
    
    fileprivate func HMACSHA1(key:String , text:String) -> String{
        let cKey =  key.cString(using: .utf8);
        let cData = text.cString(using: .utf8);
        let ckeyLen =  key.lengthOfBytes(using: .utf8)
        let cDataLen = text.lengthOfBytes(using: .utf8);
        let cHMAC = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey, ckeyLen, cData, cDataLen, cHMAC);
        let HMAC = Data.init(bytes: cHMAC, count: Int(CC_SHA1_DIGEST_LENGTH));
        let hash = urlSafeBase64Encode(data: HMAC)
        return hash;
    }
    
    public func verifyQNConfig(zone:Int? ,completion: @escaping (Result<AnyObject?>) -> Void){
        upManager = ImageServer.initQNManager(zone ?? 1);
        
        upManager.put("1".data(using: .utf8), key: nil, token: QNToken, complete: { (info, key, resp) in
            guard let _ = info, let _ = resp else {
                completion(.failure(nil))
                return
            }
            completion(.success(nil))
        }, option: nil)
    }
    
   fileprivate func arc() -> UInt32 { return arc4random() % 100000 }
    
    func timeInterval() -> Int {
        
        return Int(Date(timeIntervalSinceNow: 0).timeIntervalSince1970)
    }
  
}

// MARK: - 七牛服务，上传图片
extension ImageServer{
    
    public func QiniuUpload(_ pboard: NSPasteboard) {
        register(configDic: AppCache.shared.getQNConfig())
        createToken()
        
        let files: NSArray? = pboard.propertyList(forType: NSFilenamesPboardType) as? NSArray
        
        if let files = files {
            statusItem.button?.image = NSImage(named: "loading-\(0)")
            statusItem.button?.image?.isTemplate = true
            
            guard let _ = NSImage(contentsOfFile: files.firstObject as! String) else {
                return
            }
            QiniuSDKUpload(files.firstObject as? String, data: nil, token: QNToken)
        }
        else {
            guard let type = pboard.pasteboardItems?.first?.types.first else {
                return
            }
           
            
            guard ["public.tiff","public.png"].contains(type) else {
                return
            }
            
            let data = (pboard.pasteboardItems?.first?.data(forType: type))!
            guard let _ = NSImage(data: data) else {
                return
            }
            statusItem.button?.image = NSImage(named: "loading-\(0)")
            statusItem.button?.image?.isTemplate = true
            QiniuSDKUpload(nil, data: data, token: QNToken)
        }
       
        
    }
    
    fileprivate func QiniuSDKUpload(_ filePath: String?, data: Data?, token: String) {
        let opt = QNUploadOption(progressHandler: { (key, percent) in
            statusItem.button?.image = NSImage(named: "loading-\(Int(percent*10))")
            statusItem.button?.image?.isTemplate = true
        })
        
        
        let hanlder: (QNResponseInfo?, String?, [AnyHashable : Any]?, NSImage) -> () = { (info, key, resp, image) in
            statusItem.button?.image = NSImage(named: "StatusIcon")
            statusItem.button?.image?.isTemplate = true
            guard let _ = info, let _ = resp else {
                NotificationMessage("上传图片失败", informative: "可能是配置信息错误，或者是Token过去。请仔细检查配置信息，或重新上传")
                return
            }
            NotificationMessage("上传图片成功", isSuccess: true)
            NSPasteboard.general().clearContents()
            NSPasteboard.general()
            let picUrl = picUrlPrefix + key!
            let picUrlS  = LinkType.getLink(path:picUrl,type:AppCache.shared.linkType);
            NSPasteboard.general().setString(picUrlS, forType: NSStringPboardType)
            let cacheDic: [String: AnyObject] = ["image": image, "url": picUrl as AnyObject]
            AppCache.shared.adduploadImageToCache(cacheDic)
        }
    
        if let filePath = filePath {
            let fileName = getDateString() + "\(arc())" + NSString(string: filePath).lastPathComponent
            upManager.putFile(filePath, key: fileName, token: token, complete: { (info, key, resp) in
                hanlder(info, key, resp, NSImage(contentsOfFile: filePath)!)
            }, option: opt)
        }
        
        if var data = data {
            //进行格式转换
            if data.imageFormat == .unknown {
                let imageRep = NSBitmapImageRep(data: data)
                data = (imageRep?.representation(using: .PNG, properties: ["":""]))!
            }
            
            let fileName = getDateString() + "\(timeInterval())" + "\(arc())" + data.imageFormat.rawValue
            upManager.put(data, key: fileName, token: token, complete: { (info, key, resp) in
                hanlder(info, key, resp, NSImage(data: data)!)
            }, option: opt)
        }
    }
}


