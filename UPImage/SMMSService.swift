////
////  SMMSService.swift
////  PicU
////
////  Created by Pro.chen on 26/02/2017.
////  Copyright © 2017 chenxt. All rights reserved.
////
//
//import Cocoa
//import AFNetworking
//import Alamofire
//
//class SMMSService: NSObject {
//    static let shared = SMMSService()
//    let api = "https://sm.ms/api/upload";
//    
//    
//    func uploadImage(_ data: Data){
//        
//        
////        Alamofire.
//        Alamofire.upload(multipartFormData: { (formData) in
//            formData.append(data, withName: "smfile", fileName: "dfadfsaf.png", mimeType: "image/png");
////            formData.appendPart(withFileData: data, name: "smfile", fileName: "wkkljfs.png", mimeType: "image/png")
//        }, to: URL(string: "https://sm.ms/api/upload")!) { (encodingResult) -> Void in
//            
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    //
//                    guard let result = response.result.value else{
//                        return
//                    }
//                   print(result)
//                    
//                }
//            case .failure(let encodingError):
//                print(encodingError)
//               
//            }        }
//        
//        
////        let manager = AFHTTPSessionManager();
////        
////        
////        manager.post(api, parameters: nil, constructingBodyWith: { (formData) in
////            formData.appendPart(withFileData: data, name: "smfile", fileName: "wkkljfs.png", mimeType: "image/png")
////        }, progress: { (progress) in
////            print(progress)
////        }, success: { (URLSessionDataTask, responseObject) in
////            print(responseObject as Any);
////        }) { (URLSessionDataTask, error) in
////            print(error);
////        }
//        
//    }
//    
//
//}
