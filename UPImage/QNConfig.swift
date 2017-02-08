//
//  QNConfig.swift
//  U图床
//
//  Created by Pro.chen on 07/02/2017.
//  Copyright © 2017 chenxt. All rights reserved.
//

import Cocoa
import TMCache

class QNConfig: NSObject,NSCoding,DiskCache {
    var picUrlPrefix : String!
    var accessKey: String!
    var scope:String!
    var secretKey:String!
    var mark:String!
    var zone:Int!
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(picUrlPrefix, forKey: "picUrlPrefix")
        aCoder.encode(accessKey, forKey: "accessKey")
        aCoder.encode(scope, forKey: "scope")
        aCoder.encode(secretKey, forKey: "secretKey")
        aCoder.encode(mark, forKey: "mark")
        aCoder.encode(zone, forKey: "zone")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        picUrlPrefix = aDecoder.decodeObject(forKey: "picUrlPrefix") as! String
        accessKey = aDecoder.decodeObject(forKey: "accessKey") as! String
        scope = aDecoder.decodeObject(forKey: "scope") as! String
        secretKey = aDecoder.decodeObject(forKey: "secretKey") as! String
        mark = aDecoder.decodeObject(forKey: "mark") as! String
        zone = aDecoder.decodeObject(forKey: "zone") as! Int
    }
    
    init(picUrlPrefix:String,accessKey:String,scope:String,secretKey:String,mark:String,zone:Int) {
        self.picUrlPrefix = picUrlPrefix;
        self.accessKey = accessKey;
        self.scope = scope;
        self.secretKey = secretKey;
        self.mark = mark;
        self.zone = zone;
    }
}
