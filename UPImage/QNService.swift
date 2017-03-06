//
//  ImageServer.swift
//  U图床
//
//  Created by Pro.chen on 27/12/2016.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Foundation
import Qiniu

class QNService: NSObject {
    
    static let shared = QNService()
    fileprivate var scope : String!
    fileprivate var accessKey: String!
    fileprivate var secretKey: String!
    fileprivate var liveTime: Int!
    fileprivate var QNToken : String!
    var upManager :QNUploadManager!
    var picUrlPrefix : String!
    var mark: String!
    
    fileprivate override init() {
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
    
    public func register( config:QNConfig,liveTime:Int = 5 ){
        self.scope = config.scope;
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
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
        upManager = QNService.initQNManager(zone ?? 1);
        
        upManager.put("1".data(using: .utf8), key: nil, token: QNToken, complete: { (info, key, resp) in
            guard let _ = info, let _ = resp else {
                completion(.failure(nil))
                return
            }
            completion(.success(nil))
        }, option: nil)
    }
    

  
}

// MARK: - 七牛服务，上传图片
extension QNService{
 
    public func QiniuSDKUpload(_  data: Data?) {
        guard let qc =  AppCache.shared.qnConfig else{
            NotificationMessage("上传图片失败", informative: "请在设置中配置图床")
            return
        }
        upManager = QNService.initQNManager(qc.zone);
        picUrlPrefix = qc.picUrlPrefix;
        mark = qc.mark;
        register(config: qc)
        createToken()
        let token = QNToken
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
            let picUrl = self.picUrlPrefix + key!
            let picUrlS  = LinkType.getLink(path:picUrl,type:AppCache.shared.appConfig.linkType);
            NSPasteboard.general().setString(picUrlS, forType: NSStringPboardType)
            let cacheDic: [String: AnyObject] = ["image": image, "url": picUrl as AnyObject]
            AppCache.shared.adduploadImageToCache(cacheDic)
        }
        if let data = data {
            let fileName = getDateString() + "\(timeInterval())" + "\(arc())" + data.imageFormat.rawValue
            upManager.put(data, key: fileName, token: token, complete: { (info, key, resp) in
                hanlder(info, key, resp, NSImage(data: data)!)
            }, option: opt)
        }
    }
}


