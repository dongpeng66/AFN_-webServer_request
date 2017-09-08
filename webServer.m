//
//  webServer.m
//  webServer
//
//  Created by 人众 on 2017/9/8.
//
//

#import "webServer.h"

@implementation webServer
+ (void)soapData:(NSString *)urlStr meothName:(NSString *)meothName namePlace:(NSString *)namePlace soapBody:(NSDictionary *)soapBody success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString *soapBodyStr = soapBody.mj_JSONString;
    
    NSLog(@"%@",soapBodyStr);
    
    NSString *soapMsg= [NSString stringWithFormat:
                        @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope "
                        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                        "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                        "xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\">"
                        "<soap:Body>"
                        "<%@:xmlns=\"%@\">"
                        "<string>%@</string>"
                        "</%@>"
                        "</soap:Body>"
                        "</soap:Envelope>", meothName,namePlace,soapBodyStr,meothName];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    // 设置请求超时时间
    manager.requestSerializer.timeoutInterval = 30;
    // 返回NSData
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置请求头，也可以不设置
    [manager.requestSerializer setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%zd", soapMsg.length] forHTTPHeaderField:@"Content-Length"];
    // 设置HTTPBody
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error)
     {
         NSLog(@"%@",soapMsg);
         
         return soapMsg;
     }];
    
    [manager POST:urlStr parameters:soapMsg progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 把返回的二进制数据转为字符串
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",result);
        
        // 利用正则表达式取出<return></return>之间的字符串
        NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:@"(?<=return\\>).*(?=</return)" options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSDictionary *dict = [NSDictionary dictionary];
        for (NSTextCheckingResult *checkingResult in [regular matchesInString:result options:0 range:NSMakeRange(0, result.length)]) {
            
            // 得到字典
            dict = [NSJSONSerialization JSONObjectWithData:[[result substringWithRange:checkingResult.range] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        }
        // 请求成功并且结果有值把结果传出去
        if (success && dict) {
            success(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
    }];
    
}
@end
