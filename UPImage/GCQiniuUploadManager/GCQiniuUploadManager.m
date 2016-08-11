//
//  GCQiniuUploadManager.m
//  QiniuUploadManager
//
//  Created by 宫城 on 16/4/21.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCQiniuUploadManager.h"
#import "QNUrlSafeBase64.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "QN_GTM_Base64.h"
#import "QiniuSDK.h"

static NSInteger defaultLiveTime = 5;
static NSString *QiNiuHost = @"host";

@interface GCQiniuUploadManager ()

@property (nonatomic, assign) NSInteger index;

@end

@implementation GCQiniuUploadManager

+ (instancetype)sharedInstance {
    static GCQiniuUploadManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[GCQiniuUploadManager alloc] init];
        manager.index = 0;
    });
    return manager;
}

- (void)registerWithScope:(NSString *)scrop
                accessKey:(NSString *)accessKey
                secretKey:(NSString *)secretKey {
    [self registerWithScope:scrop accessKey:accessKey secretKey:secretKey liveTime:defaultLiveTime];
}

- (void)registerWithScope:(NSString *)scrop
                accessKey:(NSString *)accessKey
                secretKey:(NSString *)secretKey
                 liveTime:(NSInteger)liveTime {
    self.scope = scrop;
    self.accessKey = accessKey;
    self.secretKey = secretKey;
    self.liveTime = liveTime;
}

- (void)createToken {
    if (!self.scope.length || !self.accessKey.length || !self.secretKey.length) {
        return;
    }

    // 将上传策略中的scrop和deadline序列化成json格式
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
    [authInfo setObject:self.scope forKey:@"scope"];
    [authInfo
    setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] + self.liveTime * 24 * 3600]
       forKey:@"deadline"];

    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:authInfo options:NSJSONWritingPrettyPrinted error:nil];

    // 对json序列化后的上传策略进行URL安全的base64编码
    NSString *encodedString = [self urlSafeBase64Encode:jsonData];

    // 用secretKey对编码后的上传策略进行HMAC-SHA1加密，并且做安全的base64编码，得到encoded_signed
    NSString *encodedSignedString = [self HMACSHA1:self.secretKey text:encodedString];

    // 将accessKey、encodedSignedString和encodedString拼接，中间用：分开，就是上传的token
    NSString *token =
    [NSString stringWithFormat:@"%@:%@:%@", self.accessKey, encodedSignedString, encodedString];

    self.uploadToken = token;
}

- (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];

    char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self urlSafeBase64Encode:HMAC];
    return hash;
}

- (NSString *)urlSafeBase64Encode:(NSData *)text {
    NSString *base64 =
    [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}

- (void)uploadData:(NSData *)data
          progress:(UploadProgressHandler)progress
        completion:(UploadDataCompletion)completion {
    QNUploadManager *manager = [[QNUploadManager alloc] init];
    [manager putData:data
                 key:nil
               token:self.uploadToken
            complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (completion) {
                    if (info.error) {
                        completion(info.error, nil, self.index);
                    } else {
                        NSString *link =
                        [NSString stringWithFormat:@"%@/%@", QiNiuHost, resp[@"key"]];
                        completion(nil, link, self.index);
                    }
                }
            }
              option:[[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
                  if (progress) {
                      progress(percent);
                  }
              }]];
}

- (void)uploadDatas:(NSArray<NSData *> *)datas
           progress:(UploadProgressHandler)progress
  oneTaskCompletion:(UploadDataCompletion)oneTaskCompletion
 allTasksCompletion:(UploadAllTasksCompletion)allTasksCompletion {
    if (self.index < datas.count) {
        [self uploadData:datas[self.index]
        progress:^(float percent) {
            if (progress) {
                progress(percent);
            }
        }
        completion:^(NSError *error, NSString *link, NSInteger index) {
            NSLog(@"oneTaskCompletion");
            if (oneTaskCompletion) {
                oneTaskCompletion(error, link, index);
            }
            self.index++;
            [self uploadDatas:datas
                      progress:progress
             oneTaskCompletion:oneTaskCompletion
            allTasksCompletion:allTasksCompletion];
        }];
    } else {
        if (allTasksCompletion) {
            allTasksCompletion();
        }
        self.index = 0;
    }
}

@end
