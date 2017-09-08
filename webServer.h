//
//  webServer.h
//  webServer
//
//  Created by 人众 on 2017/9/8.
//
//

#import <Foundation/Foundation.h>

@interface webServer : NSObject
+ (void)soapData:(NSString *)urlStr meothName:(NSString *)meothName namePlace:(NSString *)namePlace soapBody:(NSDictionary *)soapBody success:(void (^)(id))success failure:(void (^)(NSError *))failure;
@end
