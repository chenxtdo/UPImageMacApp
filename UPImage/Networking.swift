//
//  Server.swift
//  UPImage
//
//  Created by Pro.chen on 16/7/9.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Foundation
import Alamofire

var kRootServerURL = "http://www.lzqup.com/"

public enum APIResult<Value> {
	case Success(Value)
	case Failure(NSError)
	
	public func success(@noescape success: (value: Value) -> Void) -> APIResult<Value> {
		switch self {
		case .Success(let value):
			success(value: value)
		default:
			break
		}
		
		return self
	}
	
	public func failure(@noescape failure: (error: NSError) -> Void) -> APIResult<Value> {
		switch self {
		case .Failure(let error):
			failure(error: error)
		default:
			break
		}
		return self
	}
}

public struct Resource: CustomStringConvertible {
	
	let url: String
	let method: Alamofire.Method
	let param: [String: AnyObject]?
	let headers: [String: String]?
	
	public var description: String {
		var pa = url + "?"
		
		if let param = param {
			_ = param.map({ key, value in
				pa = pa + key + "=" + "&"
			})
			pa.removeAtIndex(pa.endIndex.predecessor())
		}
		return pa
	}
	
	public init(path: String, method: Alamofire.Method, param: [String: AnyObject]?, headers: [String: String]?) {
		self.url = kRootServerURL + path
		self.method = method
		self.param = param
		self.headers = headers
	}
	
}

func HttpRequest(resource: Resource, completion: APIResult<AnyObject> -> Void) {
	
	Alamofire.request(resource.method, resource.url, parameters: resource.param, headers: resource.headers)
		.responseJSON {
			response in
			guard response.result.isSuccess else {
				completion(.Failure(NSError(domain: "网络请求错误", code: 404, userInfo: nil)))
				return
			}
			
			guard let jsonValue = response.result.value else {
				completion(.Failure(NSError(domain: "网络请求错误", code: 400, userInfo: nil)))
				return
			}
			
			guard let code = jsonValue.valueForKey("code") else {
				completion(.Failure(NSError(domain: "网络请求错误", code: 405, userInfo: nil)))
				return
			}
			guard code.integerValue == 1 else {
				
				completion(.Failure(NSError(domain: (jsonValue.valueForKey("message") as? String)!, code: code.integerValue, userInfo: nil)))
				return
			}
			
			completion(.Success(jsonValue))
			
	}
}

