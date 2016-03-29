//
//  ZMServerAPIs.m
//  ZMSD
//
//  Created by zima on 14-11-5.
//  Copyright (c) 2014年 zima. All rights reserved.
//

#import "ZMServerAPIs.h"
#import "Base64.h"
#import "Base64Defines.h"
#import "HUD.h"
//DES编码
#import "DESUtil.h"

/*
//移动端服务接口地址(外网地址)：
//http://182.92.217.163:8080/mobile/
//
//内网地址是：
//http://10.146.11.25:8080/mobile/
//
//目前提供：登录、注册、找回密码、债权这几个模块的接口
*/

//内网接口（龙川电脑）
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.1.118/%@", subPath]
    
//内网接口（庞立坤电脑）
//#define SERVER_REQUEST_INTERFACE(subPath)          [NSString stringWithFormat:@"http://192.168.1.134:8080/mobile/%@", subPath]

//内网接口（梅元勋电脑）
//#define SERVER_REQUEST_INTERFACE(subPath)          [NSString stringWithFormat:@"http://192.168.1.135:80/mobile/%@", subPath]

//内网接口（杨阳电脑）
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.1.118:8088/mobile/%@", subPath]

//内网接口（陈东电脑）
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.1.121:8080/mobile/%@", subPath]


//外网接口（204 test数据库）
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://182.92.167.204:8090/mobile/%@", subPath]

//正式地址
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://112.126.76.199:9080/mobile/%@", subPath]

//木兰财行（临时）
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.1.250:8080/mobile/%@", subPath]

//正式接口
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://101.200.185.254:8083/%@", subPath]


//苏克
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.3.58:8070/mobile/%@", subPath]
//#define MAIN_SERVER_REQUEST_INTERFACE     @"http://192.168.3.58:8070/mobile/"

//大哥
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.3.5:8080/mobile/%@", subPath]
//#define MAIN_SERVER_REQUEST_INTERFACE     @"http://192.168.3.5:8080/mobile/"

//测试环境
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://192.168.3.62:8084/%@", subPath]
//#define MAIN_SERVER_REQUEST_INTERFACE    @"http://192.168.3.62:8084/"

//阿里测试环境
#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http:101.200.238.144:18080/mobile/%@", subPath]
#define MAIN_SERVER_REQUEST_INTERFACE     @"http://101.200.238.144:18080/mobile/"

//测试打包地址
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"http://test.caihangjia.com/mobile/%@", subPath]
//#define MAIN_SERVER_REQUEST_INTERFACE     @"http://test.caihangjia.com/mobile/"


//正式接口
//#define SERVER_REQUEST_INTERFACE(subPath)        [NSString stringWithFormat:@"https://mobile.caihangjia.com/%@", subPath]
//#define MAIN_SERVER_REQUEST_INTERFACE     @"https://mobile.caihangjia.com/"


//#define MAIN_SERVER_REQUEST_INTERFACE    @"http://192.168.3.62:8084/"
//测试接口
//#define MAIN_SERVER_REQUEST_INTERFACE     @"http://192.168.3.75:8080/mobile/"
//正式接口
//#define MAIN_SERVER_REQUEST_INTERFACE     @"http://101.200.185.254:8083/"
//http://192.168.3.20/

//返回json的样式类型
enum{
    ReturnTypeNormal = 0,       //code 和 result 都有，并且不在同一层级上边
    ReturnTypeSameLevel = 1,    //code 和 result 都有，但在同一层级上边
    ReturnTypeOnlyCode = 2,     //返回json中只有code字段
    ReturnTypeOnlyResult = 3,   //无
};
typedef NSUInteger returnSuccessType;



static ZMServerAPIs *shareZMServerAPIs;
static int requestInterval  =  60;

/**
 *  优先使用POST模式
 */
static BOOL POST_MODE = YES;


@interface ZMServerAPIs ()
{
    NSOperationQueue        *mainCurrentQueue;
}
@end

@implementation ZMServerAPIs


/**
 *  获取设备UUID
 *
 *  @return 返回设备的UUID
 */
- (NSString *) getCurrentDeviceUUID
{
    NSString *uuidString = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CLog(@"uuidString = %@", uuidString);
    return uuidString;
}

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString*)base64encode:(NSString*)str
{
    
    if ([str length] == 0)
        
        return @"";
    
    const char *source = [str UTF8String];
    
    int strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    
    if (characters == NULL)
        
        return nil;
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    
    while (i < strlength) {
        
        char buffer[3] = {0,0,0};
        
        short bufferLength = 0;
        
        while (bufferLength < 3 && i < strlength)
            
            buffer[bufferLength++] = source[i++];
        
        characters[length++] = base64[(buffer[0] & 0xFC) >> 2];
        
        characters[length++] = base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        
        if (bufferLength > 1)
            
            characters[length++] = base64[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        
        else characters[length++] = '=';
        
        if (bufferLength > 2)
            
            characters[length++] = base64[buffer[2] & 0x3F];
        
        else characters[length++] = '=';
        
    }
    
    NSString *g = [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
    return g;
    
}



+(ZMServerAPIs *)shareZMServerAPIs
{
    if (shareZMServerAPIs == nil) {
        shareZMServerAPIs = [[ZMServerAPIs alloc]init];
    }
    return shareZMServerAPIs;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        //队列
        mainCurrentQueue = [[NSOperationQueue alloc] init];
        mainCurrentQueue.maxConcurrentOperationCount = 1;
        [mainCurrentQueue setSuspended:NO];      //设置是否暂停
    }
    return self;
}

// 将字典或者数组转化为JSON串
- (NSData *)toJSONData:(id)theData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

//根据枚举类型返回正式字符类型
- (NSString *)getLoanTypeNameByType:(ZMLoanType)loanType
{
    switch (loanType) {
        case ZMLoanType_RIZIBAO:
            return @"RIZIBAO";
            break;
        case ZMLoanType_YUEMANYING:
            return @"YUEMANYING";
            break;
        case ZMLoanType_JIJIFENG:
            return @"JIJIFENG";
            break;
        case ZMLoanType_SHUANGJIXIN:
            return @"SHUANGJIXIN";
            break;
        case ZMLoanType_NIANNIANHONG:
            return @"NIANNIANHONG";
            break;
        case ZMLoanType_RONGZI:
//            return @"RONGZI"; //紫贷宝（废弃）
            return @"ZIDAIBAO"; //紫贷宝（废弃）
            break;
        case ZMLoanType_PEIZI:
            return @"PEIZIDAI";  //配紫贷
            break;
        case ZMLoanType_DANBAO:
            return @"DANBAODAI"; //担保贷
            break;
        case ZMLoanType_BAOLI:
//            return @"BAOLI";  //消费贷
            return @"XIAOFEIDAI";  //消费贷
            break;
        case ZMLoanType_QICHE:
            return @"QICHEDAI";  //汽车贷
            break;
        case ZMLoanType_GONGYLJR:
            return @"GONGYLJR";  //供应链金融
            break;
            
        case ZMLoanType_ZIDINGYING:
            return @"ZIDINGYING";  //紫定盈
            break;
        case ZMLoanType_ZIDAIBAO:
            return @"ZIDAIBAO";  //紫贷宝
            break;
        case ZMLoanType_YHPJ:   //  银行票据
            return @"YHPJ";
            break;
        case ZMLoanType_YSZK:   //  营收账款
            return @"YSZK";
            break;
        default:
            break;
    }
    return nil;
}
- (NSString *)getLoanStateType:(ZMLoanState)loanstate
{
    switch (loanstate) {
        case FULL_LOAN:
            return @"FULL_LOAN";
            break;
        case LOAN_PROGRESS:
            return @"LOAN_PROGRESS";
            break;
        case RECEIVING_PROGRESS:
            return @"RECEIVING_PROGRESS";
            break;
        default:
            break;
    }
    return nil;

}
- (NSString *)getLoanStateName:(NSString *)loanStateName
{
    if([loanStateName isEqualToString:@"FULL_LOAN"])
        return @"满标中";
    if([loanStateName isEqualToString:@"LOAN_PROGRESS"])
        return @"招标中";
    if([loanStateName isEqualToString:@"RECEIVING_PROGRESS"])
        return @"还款中";
    return nil;
}


//根据正式字符类型返回中文名称
- (NSString *)getLoanCNNameByLoanTypeName:(NSString *) loanTypeName
{
    if([loanTypeName isEqualToString:@"RIZIBAO"])
       return @"活期标";
    if([loanTypeName isEqualToString:@"YUEMANYING"])
        return @"定期标";
    if([loanTypeName isEqualToString:@"JIJIFENG"])
        return @"定期标";
    if([loanTypeName isEqualToString:@"SHUANGJIXIN"])
        return @"双季鑫";
    if([loanTypeName isEqualToString:@"NIANNIANHONG"])
        return @"年年红";
    if([loanTypeName isEqualToString:@"CAIXIANGYU"])
        return @"新手标";
    
    if([loanTypeName isEqualToString:@"MORE_DAY"])
        return @"体验标";
    
    if([loanTypeName isEqualToString:@"ZIDAIBAO"] ||
       [loanTypeName isEqualToString:@"RONGZI"])
        return @"紫贷宝";
    if([loanTypeName isEqualToString:@"PEIZIDAI"] ||
       [loanTypeName isEqualToString:@"PEIZI"])
        return @"配紫贷";
    if([loanTypeName isEqualToString:@"DANBAODAI"] ||
       [loanTypeName isEqualToString:@"DANBAO"])
        return @"担保贷";
    if([loanTypeName isEqualToString:@"XIAOFEIDAI"]  ||
       [loanTypeName isEqualToString:@"BAOLI"])
        return @"消费贷";
    if([loanTypeName isEqualToString:@"QICHEDAI"] ||
       [loanTypeName isEqualToString:@"QICHE"])
        return @"汽车贷";
    if([loanTypeName isEqualToString:@"GONGYLJR"])
        return @"供应链";
    
    if([loanTypeName isEqualToString:@"ZIDINGYING"])
        return @"紫定盈";
    if([loanTypeName isEqualToString:@"YHPJ"])
        return @"银行票据";
    if([loanTypeName isEqualToString:@"YSZK"])
        return @"营收账款";
    return nil;
}

//公共数据
- (NSDictionary *)commonBean
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    timeInterval = floor(timeInterval *1000);
    
    NSMutableDictionary * dic  = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"clientTime"];
    [dic setObject:[NSNumber numberWithInteger:1] forKey:@"clientType"];//iOS == 1
    [dic setObject:[NSNumber numberWithInteger:1] forKey:@"APP_VERSION"];
    return dic;
}

#pragma mark --------------- 充值 提现 --------------------------------
//申请提现
- (void)getCashWithAmount:(double)amount andUserBankId:(NSInteger)userBankId branchName:(NSString *)branchName cityId:(NSInteger)cityId Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = @"24/withdrawal";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
//    [requestDic setObject:[NSNumber numberWithFloat:amount] forKey:@"amount"];
    [requestDic setObject:[NSString stringWithFormat:@"%.2f",amount] forKey:@"amount"];
    
    [requestDic setObject:[NSNumber numberWithInteger:userBankId] forKey:@"userBankId"];
    
    [requestDic setObject:branchName forKey:@"branchName"];
    [requestDic setObject:[NSNumber numberWithInteger:cityId] forKey:@"cityId"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"申请提现"
                            success:success
                            failure:failure];
}

//充值
- (void)rechargeWithAmount:(double)amount andBankCardNumber:(NSString *)bankCardNumber Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = @"43/recharge";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithDouble:amount] forKey:@"amount"];
    [requestDic setObject:bankCardNumber forKey:@"bankCardNumber"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"手机充值"
                            success:success
                            failure:failure];
}

//用户是否首次充值
- (void)isFirstRechargeSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = @"20/perpaidinfo";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"用户是否首次充值"
                            success:success
                            failure:failure];
}
#pragma mark --------------- FTP相关接口 --------------------------------
- (void)getFtpInfoSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"67/GetFTPInfo"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取FTP相关信息"
                            success:success
                            failure:failure];

}
#pragma mark -----------------------------资金流水--------------------------------------

-(void)getCashRecordNewByPage:(NSInteger)pageIndex RowCount:(NSInteger)pageSize Type:(NSString*)type Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"getCapitalRecordNew"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];

    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];

    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"rows"];
    [requestDic setObject:type forKey:@"type"];
    
    [requestDic addEntriesFromDictionary:[self commonBean]];

    
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    NSString *description = @"获取资金流水记录";
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            success(dicty);
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];
    
}

//废弃
-(void)getCashRecordsByUserId:(int)userId Page:(NSInteger)pageIndex RowCount:(NSInteger)pageSize Type:(NSString*)type Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"getCapitalRecord"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic setObject:[NSNumber numberWithInt:userId] forKey:@"userId"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
     [requestDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"rows"];
    [requestDic setObject:type forKey:@"type"];

    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取资金流水的记录"
                            success:success
                            failure:failure];
}
#pragma mark ---------------注册、登录、找回密码等等相关--------------------------------

/**
 *  注册第1步：获取验证码
 *
 *  @param mobileNumber
 *  @param messageType: (RIGIST, BIND_MOBILE, BIND_EMAIL, REVISE_MOBILE, REVISE_EMAIL)
 *  @param success
 *  @param failure
 */
-(void)requestVerifyCodeWithUID:(NSString *)mobileNumber withMessageType:(NSString *)messageType Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"3/%@", mobileNumber];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:messageType forKey:@"messageType"];
    
    
    
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    CLog(@"最后封装的JSON = %@", jsonString);
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    
    
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    CLog(@"last url %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if (httpBodyData == nil) {
    }
    else
    {
        [request setHTTPBody:httpBodyData];
    }
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
//            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
//            CLog(@"%@ 接收到的数据：%@", description, receivedStr);
            //            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    success(dicty);
                    [self checkingIfLoginOnOtherDevice:dicty];
                }
            }
        }
    }];
    
    
//    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"注册－获取验证码" success:success failure:failure];
}

-(void)registerPhoneNumber:(NSString *)mobileNumber Password:(NSString *)password Code:(NSString *)captcha shareCode:(NSString *)shareCode Success:(void(^)(id response))success failure:(void(^)(id response))failure

//-(void)registerPhoneNumber:(NSString *)mobileNumber Password:(NSString *)password Code:(NSString *)captcha Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"1/%@", mobileNumber];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:password forKey:@"pwd"];
    [requestDic setObject:captcha forKey:@"captcha"];
    [requestDic setObject:shareCode forKey:@"shareCode"];
    [requestDic setObject:[NSNumber numberWithBool:YES] forKey:@"isAgree"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"注册"
                            success:success
                            failure:failure];
}

/*
 *  忘记密码／找回密码
 */
-(void)forgotPasswordPhoneNumber:(NSString *)mobileNumber Password:(NSString *)password Code:(NSString *)captcha Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"66/ForgotPwd/%@", mobileNumber];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:password forKey:@"newpassword"];
    [requestDic setObject:captcha forKey:@"captcha"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"忘记密码／找回密码"
                            success:success
                            failure:failure];
}

/**
 *  获取协议
 *
 *  @param agreementTypeName
 *  @param value
 *  @param success
 *  @param failure
 */
- (void)getAgreementWithAgreementType:(NSString *)value ProductId:(NSString*)Id lendTime:(NSString *)lendTime Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
//    [self doHttpRequestWithHttpBody:nil Action:@"35/agreement/REGISTRATION_AGREEMENT" Description:@"注册协议" success:success failure:failure];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setValue:lendTime forKey:@"lendTime"];
    [requestDic setValue:Id forKey:@"productId"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:[NSString stringWithFormat:@"35/agreement/%@",value]
                        Description:@"紫定盈协议"
                            success:success
                            failure:failure];

    return;
}

#pragma mark ---------------登录接口相关--------------------------------

/**
 *  登录
 *
 *  @param userId
 *  @param password
 */
-(void)loginWithUID:(NSString *)tempUserId PWD:(NSString *)tempPassword Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"2/%@", tempUserId];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:tempPassword forKey:@"pwd"];
    [requestDic setObject:[NSNumber numberWithBool:YES] forKey:@"isAgree"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"登录"
                            success:success
                            failure:failure];
}


/*
 * 修改密码
 */
-(void)modifyPassword:(NSString *)oldPWD withNewPassword:(NSString *)newPWD Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"11/password"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:oldPWD forKey:@"oldPassword"];
    [requestDic setObject:newPWD forKey:@"newPassword"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"修改密码"
                            success:success
                            failure:failure];
}

#pragma mark ----------------------日紫宝赎回-------------------------
//日紫宝赎回
-(void)ransomRizibaoWithAmount:(double)amount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"27/ransom"];//38/dailyRansom
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithDouble:amount] forKey:@"amount"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"日紫宝赎回"
                            success:success
                            failure:failure];
}

//获取日紫宝信息
- (void)getRizibaoInfoSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"37/initDailyRansom"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"日紫宝当前状态信息"
                            success:success
                            failure:failure];
}

#pragma mark ----------------------消息列表、设置--------------------
//获取消息设置
- (void)getMessageSettingsSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"28/messageSetting"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取消息设置"
                            success:success
                            failure:failure];
}

//设置消息已读
- (void)setReadedMessageWithMsgId:(NSInteger)msgId Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"31/readMessage"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithInteger:msgId] forKey:@"msgId"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"设置已读短信"
                            success:success
                            failure:failure];
}

//获取消息列表
- (void)getMessageListWithPageIndex:(NSInteger)pageIndex Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"30/message"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:@10 forKey:@"pageSize"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取消息列表"
                            success:success
                            failure:failure];
}

- (void)setMsgSettingsWithOpenSms:(NSMutableArray *)openSmsArray andOpenInstaion:(NSMutableArray *)openInstationSmsArray andOpenEmail:(NSMutableArray *)openEmailArray Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"29/messageSetting"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:openSmsArray forKey:@"openSms"];
    [requestDic setObject:openInstationSmsArray forKey:@"openInstationSms"];
    [requestDic setObject:openEmailArray forKey:@"openEmail"];
    [requestDic setObject:@"ios" forKey:@"flag"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"设置消息设置"
                            success:success
                            failure:failure];
}


//消息总数
-(void)getMsgCountSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    if (loginKey == nil)
    {
        return;
    }
    NSString *actionName = [NSString stringWithFormat:@"69/getUserhasReadMsg/%@", loginKey];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取消息总数"
                            success:success
                            failure:failure];
}

#pragma mark ----------------------奖励管理-------------------------
/*
 condition:"Used"返回已使用的红包,
           "UnUsed"返回未使用的红包,
           "ALL"返回所有红包
 */
-(void)getUserRedPackageWithCondition:(NSString *)condition Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"23/coupon"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:condition forKey:@"enable"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"我的红包"
                            success:success
                            failure:failure];
}


//邀请好友
-(void)inviteFriendsWithMobile:(NSString *)moblieNumber andName:(NSString *)name Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"26/inviteByMobile"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:moblieNumber forKey:@"mobile"];
    [requestDic setObject:name forKey:@"name"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"短信邀请好友"
                            success:success
                            failure:failure];
}

//获取邀请链接
- (void)getInviteFriendsUrlSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"25/inviteUrl"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取邀请链接"
                            success:success
                            failure:failure];
}

//获取邀请亲友
- (void)getMyInviteFriendsWithPageIndex:(NSInteger)pageIndex Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"39/inviteFriends"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"pageNum"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取我邀请的亲友"
                            success:success
                            failure:failure];
}

//获取投资详情
- (void)getAssetInfoWithBidUserId:(NSString *)bidUserId andFpUserId:(NSString *)fpUserId Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"41/myDetailPage"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:bidUserId forKey:@"bidUserId"];
    [requestDic setObject:fpUserId forKey:@"fpUserId"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取投资详情"
                            success:success
                            failure:failure];
}

#pragma mark ---------------用户资金，基本，账户信息--------------------------------

//资金信息
-(void)getUserAssertSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"9/userAssert"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"用户（资金）信息"
                            success:success
                            failure:failure];
}

//个人基本信息
-(void)getUserBaseInfoSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"5/userInfo"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"用户（基本）信息"
                            success:success
                            failure:failure];
}

//账户信息
-(void)getUserAccountSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"10/account"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"用户（账户）信息"
                            success:success
                            failure:failure];
}

//上传头像


//请求数据的封装
-(NSData *)packageTheRequestDataForAvatar:(NSMutableString *)requestDic
{
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return httpBodyData;
}



-(void)uploadAvatar:(NSData *)dataFile Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"15/avartar"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
//    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:@"hhhhhhhh" forKey:@"file"];
    
//    NSString *base64String = [Base64 stringByEncodingData:dataFile]; //UIImagePNGRepresentation(contentImage)
//    
//    [requestDic setObject:base64String forKey:@"file"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"上传用户头像"
                            success:success
                            failure:failure];
    
    return;
    
//    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
//                              image:dataFile
//                             Action:actionName
//                        Description:@"上传用户头像"
//                            success:success
//                            failure:failure];
    
    
    
    
    
//    NSData *httpBodyData = [self packageTheRequestData:requestDic];
    
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    
    
    
    
    //组装数据
    ////
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"loginKey"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",loginKey];
    
    //图片
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"propeller.png\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    
    //声明结束符：--AaB03x--
    NSString *end = [[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    
     NSMutableData *myRequestData = [NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
//    [myRequestData appendData:[self packageTheRequestDataForAvatar:body]];
    //[body dataUsingEncoding:NSUTF8StringEncoding];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [myRequestData appendData:dataFile];//图片
    
    
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
     
    ////
    
    
    
    
    
    
    
    
    
//    if (httpBodyData == nil) {
//    }
//    else
//    {
//        [request setHTTPBody:httpBodyData];
//    }
    
//    if (dataFile == nil) {
//    }
//    else
//    {
//        [request setHTTPBody:dataFile];
//    }
    
    
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    
    //设置http body
    [request setHTTPBody:myRequestData];
    
    
    
    
    
    
    
    
    
//    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", @"上传图片", (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"上传图片 接收到的数据：%@", receivedStr);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];
    
}

//更新用户基本信息
-(void)updateUserBaseInfo:(NSDictionary *)baseInfo Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"14/updateUserInfo"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [requestDic addEntriesFromDictionary:baseInfo];
    
//    [requestDic setObject:@"" forKey:@"educationalType"];
//    [requestDic setObject:@"" forKey:@"residentialAddress"];
//    [requestDic setObject:@"" forKey:@"graduateInstitutions"];
//    [requestDic setObject:@"" forKey:@"marriageStatus"];
//    [requestDic setObject:@"" forKey:@"companyIndustry"];
//    [requestDic setObject:@"" forKey:@"companyScale"];
//    [requestDic setObject:@"" forKey:@"position"];
//    [requestDic setObject:@"" forKey:@"incomeMonthly"];
    
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"更新用户基本信息"
                            success:success
                            failure:failure];
}






#pragma mark --------------- 获取首页广告 --------------------------------
//获取首页广告
-(void)getAdBannersSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"4/banner"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"首页广告Banner"
                            success:success
                            failure:failure];
}



#pragma mark --------------- 首页产品，我要投资产品列表 --------------------------------

-(void)recommendedItemsSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"0/ALL"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"首页推荐项目"
                            success:success
                            failure:failure];
}

//获取产品列表
-(void)getProductListByCategoryType:(NSString *)productType Page:(NSInteger)pageIndex RowCount:(NSInteger)rowCount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"6/list"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:productType forKey:@"productType"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:rowCount] forKey:@"pageSize"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取产品列表"
                            success:success
                            failure:failure];
}

//获取项目详细信息
-(void)getProductDetailWithType:(NSString *)loanType LoanId:(long)loanId success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"7/detail/%@/%ld", loanType, loanId];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>项目详细信息", loanType]
                            success:success
                            failure:failure];
}

- (void)getAssetRecordsWithLoanType:(NSString *)loanType andLoanId:(long)loanId andPage:(NSInteger)page andPageSize:(NSInteger)pageSize Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"8/%@/%ld", loanType, loanId];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>项目投资记录", loanType]
                            success:success
                            failure:failure];
}


#pragma mark --------------- 产品的投资记录 --------------------------------

-(void)getProductInvestRecordsByCategoryType:(NSString *)type Id:(long)productId Page:(NSInteger)pageIndex RowCount:(NSInteger)pageSize Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"8/%@/%ld", type, productId];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"pageSize"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>产品的投资记录", type]
                            success:success
                            failure:failure];
}
#pragma mark --------------- 个人投资记录 --------------------------------

-(void)getMyProductInvestRecordsByCategoryType:(NSString *)type Id:(int)userId Page:(NSInteger)pageIndex RowCount:(NSInteger)pageSize loanStatus:(NSString *)loanStatus payStatus:(NSString *)payStatus Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"getLoanLenderRecords.action"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setValue:[NSNumber numberWithInt:userId] forKey:@"userId"];
    [requestDic setValue:type forKey:@"productType"];
    [requestDic setValue:loanStatus forKey:@"loanStatus"];
    [requestDic setValue:payStatus forKey:@"payStatus"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"rows"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>产品的投资记录", type]
                            success:success
                            failure:failure];
}




/**
 *  http请求公共方法（私有）
 *
 *  @param httpBodyData  post请求的body
 *  @param actionName    事件名称
 *  @param description   说明文字，用户调试使用
 *  @param success       block
 *  @param failure       block
 */
-(void)do1HttpRequestWithHttpBody:(NSData *)httpBodyData Action:(NSString *)actionName Description:(NSString *)description success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    CLog(@"last url %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if (httpBodyData == nil) {
    }
    else
    {
        [request setHTTPBody:httpBodyData];
    }
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
                        CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
                        CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];
}

#pragma mark --------------- 确认投资 --------------------------------

//loan 紫贷宝
//productPhase 紫定赢
-(void)confirmInvestmentWith:(NSInteger)proId LoanId:(NSString *)loanId loanType:(NSString *)loanTypeName andLendAmount:(double)lendAmount Coupons:(NSString *)couponsStr success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName;
    NSString *categoryKey;
    //紫定赢
    if([loanTypeName isEqualToString:@"RIZIBAO"] ||
       [loanTypeName isEqualToString:@"YUEMANYING"]||
       [loanTypeName isEqualToString:@"JIJIFENG"] ||
       [loanTypeName isEqualToString:@"SHUANGJIXIN"] ||
       [loanTypeName isEqualToString:@"NIANNIANHONG"] ||
       [loanTypeName isEqualToString:@"MORE_DAY"]||
       [loanTypeName isEqualToString:@"CAIXIANGYU"])
    {
        actionName = [NSString stringWithFormat:@"22/productPhase/%ld", proId];
        categoryKey = @"productPhaseId";
    }
    //紫贷宝
    else if([loanTypeName isEqualToString:@"ZIDAIBAO"] ||
            [loanTypeName isEqualToString:@"RONGZI"] ||
            [loanTypeName isEqualToString:@"PEIZIDAI"] ||
            [loanTypeName isEqualToString:@"PEIZI"] ||
            [loanTypeName isEqualToString:@"DANBAODAI"] ||
            [loanTypeName isEqualToString:@"DANBAO"] ||
            [loanTypeName isEqualToString:@"XIAOFEIDAI"] ||
            [loanTypeName isEqualToString:@"BAOLI"] ||
            [loanTypeName isEqualToString:@"QICHEDAI"] ||
            [loanTypeName isEqualToString:@"QICHE"] ||
             [loanTypeName isEqualToString:@"YHPJ"] ||
             [loanTypeName isEqualToString:@"YSZK"] ||
            [loanTypeName isEqualToString:@"GONGYLJR"])
    {
        actionName = [NSString stringWithFormat:@"21/loan/%ld", proId];
        categoryKey = @"loanId";
    }
    
    
//    NSString *actionName = [NSString stringWithFormat:@"21/%@/%ld", mainCategory, loanId];
//    NSString *actionName = [NSString stringWithFormat:@"22/productPhase"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [requestDic setObject:[NSNumber numberWithDouble:lendAmount] forKey:@"amount"];
    
//    [requestDic setObject:couponsStr forKey:@"coupons"];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [requestDic setObject:loanId forKey:categoryKey];     
    
    CLog(@"投资信息requestDic ===== %@ , actionName = %@", requestDic, actionName);
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"确认投资 loan id %@", loanId]
                            success:success
                            failure:failure];
}





#pragma mark ---------------添加银行卡相关接口--------------------------------
//添加银行卡
- (void)addBankCardWithBankId:(NSInteger)bankId andCardNumber:(NSString *)cardNumber andBranchName:(NSString *)branchName andCityId:(NSInteger)cityId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"15/userbank"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [requestDic setObject:[NSNumber numberWithInteger:bankId] forKey:@"bankId"];
    [requestDic setObject:cardNumber forKey:@"cardNumber"];
    [requestDic setObject:branchName forKey:@"branchName"];
    [requestDic setObject:[NSNumber numberWithInteger:cityId] forKey:@"cityId"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"添加银行卡"
                            success:success
                            failure:failure];
}

//获取用户银行卡列表
- (void)getUserBankListForWithdraw:(BOOL)isWithdraw Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"19/userbank"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    [requestDic setObject:[NSNumber numberWithBool:isWithdraw] forKey:@"isWithdraw"];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取用户银行卡列表"
                            success:success
                            failure:failure];
}

//解绑银行卡
- (void)deleteUserBankWithUserBankId:(NSInteger)userBankId Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"16/userbank"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSNumber numberWithInteger:userBankId] forKey:@"userBankId"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"解绑银行卡"
                            success:success
                            failure:failure];

}

/*
 * 获取银行名称列表
 */
- (void)bankNameListSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    CLog(@"UFT8编码 %@", encodedString);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    CLog(@"加密后 = %@",jsonString);
    //    CLog(@"解密后 = %@", __DES_DECOED_TEXT(jsonString));
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    CLog(@"最后封装的JSON = %@", jsonString);
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:@"17/banks" Description:@"添加银行卡" success:success failure:failure];
}

/*
 * 获取省份列表
 */

//添加银行卡：{"message":"获取数据成功","data":{"provinces":["北京","天津","上海","重庆","安徽省","福建省","甘肃省","广东省","贵州省","河北省","黑龙江省","河南省","湖北省","湖南省","吉林省","江西省","江苏省","辽宁省","山东省","陕西省","山西省","四川省","云南省","浙江省","青海省","海南省","广西壮族","内蒙古","宁夏回族","西藏","新疆维吾尔","香港","澳门","台湾省"]},"code":1000}
- (void)bankProvinceListSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    
//    [requestDic setObject:@"fd07859c-270d-48b7-bfc9-48a6d57ab7cc" forKey:@"loginKey"];
    
    
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    //UFT8编码&URL
    //    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
    //                                                                                            (__bridge CFStringRef)jsonString,
    //                                                                                            NULL,
    //                                                                                            NULL,  kCFStringEncodingUTF8 );
    //    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    CLog(@"UFT8编码 %@", encodedString);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    CLog(@"加密后 = %@",jsonString);
    //    CLog(@"解密后 = %@", __DES_DECOED_TEXT(jsonString));
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    CLog(@"最后封装的JSON = %@", jsonString);
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:@"17/province" Description:@"添加银行卡" success:success failure:failure];
}


/*
 * 获取省份列表
 */
- (void)bankCityListWithProvice:(NSString *)proviceName Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:proviceName forKey:@"province"];
    
    
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    //UFT8编码&URL
    //    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
    //                                                                                            (__bridge CFStringRef)jsonString,
    //                                                                                            NULL,
    //                                                                                            NULL,  kCFStringEncodingUTF8 );
    //    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    CLog(@"UFT8编码 %@", encodedString);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    CLog(@"加密后 = %@",jsonString);
    //    CLog(@"解密后 = %@", __DES_DECOED_TEXT(jsonString));
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    CLog(@"最后封装的JSON = %@", jsonString);
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:@"18/city" Description:@"城市列表" success:success failure:failure];
}



#pragma Mark   -------------  安全认证相关  ----------------

//实名认证
-(void)setRealName:(NSString *)realName identityNumber:(NSString *)idNum success:(void(^)(id response))success
           failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"36/authUser"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:realName forKey:@"name"];
    [requestDic setObject:idNum forKey:@"idNumber"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"安全认证－实名认证"
                            success:success
                            failure:failure];
}

//修改密码
- (void)alterUserOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"11/password"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:oldPassword forKey:@"oldPassword"];
    [requestDic setObject:newPassword forKey:@"newPassword"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"修改密码"
                            success:success
                            failure:failure];
}
#pragma mark --------------- 回款记录 --------------------------------


///**
// * 获取用户回款记录列表
// */
//userId
//page
//rows
// getLoanPharses.action
-(void)requestPaymentRecordsListByUserId:(NSInteger)userId page:(NSInteger)pageIndex rowCount:(NSInteger)rowCount loanPhaseStatus:(NSString *)loanPhaseStatus  Success:(void(^)(id response))success failure:(void(^)(id response))failure

{
    NSString *actionName = @"getLoanPharses.action";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    [requestDic setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [requestDic setObject:[NSNumber numberWithInteger:rowCount] forKey:@"rows"];
    [requestDic setValue:@"other" forKey:@"productType"];
    [requestDic setValue:loanPhaseStatus forKey:@"loanPhaseStatus"];
    
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"回款计划"
                            success:success
                            failure:failure];
}
//验证旧手机号码获取验证码
- (void)getIdentifyCodeByOldMobile:(NSString *)mobile Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"44/getOldMobileIdentifyingCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:mobile forKey:@"mobile"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取旧手机验证码"
                            success:success
                            failure:failure];

}

//验证新手机号码获取验证码
- (void)getIdentifyCodeByNewMobile:(NSString *)mobile Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"45/getNewMobileIdentifyingCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:mobile forKey:@"mobile"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取新手机验证码"
                            success:success
                            failure:failure];
}

//验证旧绑定手机
- (void)checkOldMobile:(NSString *)mobile andIdentifyCode:(NSString *)code Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"46/checkOldMobileCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:mobile forKey:@"mobile"];
    [requestDic setObject:code forKey:@"code"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"验证旧绑定手机"
                            success:success
                            failure:failure];
}

//重新绑定手机
- (void)rebindMobileWithNewMobile:(NSString *)newMobile andIdentifyCode:(NSString *)code Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"47/updateBindMobilePhone"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:newMobile forKey:@"mobile"];
    [requestDic setObject:code forKey:@"code"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"重新绑定手机"
                            success:success
                            failure:failure];
}

//验证旧邮箱获取验证码
- (void)getIdentifyCodeByOldEmail:(NSString *)email Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"48/sendOldMailCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:email forKey:@"email"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取旧邮箱验证码"
                            success:success
                            failure:failure];
    
}

//验证新邮箱号码获取验证码
- (void)getIdentifyCodeByNewEmail:(NSString *)email Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"50/sendNewMailCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:email forKey:@"email"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取新邮箱验证码"
                            success:success
                            failure:failure];
}

//验证旧绑定邮箱
- (void)checkOldEmail:(NSString *)email andIdentifyCode:(NSString *)code Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"49/checkMailCode"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:email forKey:@"email"];
    [requestDic setObject:code forKey:@"code"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"验证旧绑定邮箱"
                            success:success
                            failure:failure];
}

//重新绑定邮箱
- (void)rebindEmailWithNewEmail:(NSString *)newEmail andIdentifyCode:(NSString *)code Success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"51/updateUserEmailInfo"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:newEmail forKey:@"email"];
    [requestDic setObject:code forKey:@"code"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"重新绑定邮箱"
                            success:success
                            failure:failure];
}

#pragma Mark   -------------  http request 公共  ----------------

//请求数据的封装
-(NSData *)packageTheRequestData:(NSMutableDictionary *)requestDic
{
    //转成字符串
    NSData *bodyData = [self toJSONData:requestDic];
    NSString *jsonString = [[NSString alloc] initWithData:bodyData
                                                 encoding:NSUTF8StringEncoding];
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)jsonString,
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8);
    
    jsonString = encodedString;
    
    
    //DES加密
    jsonString = __DES_ENCOED_BASE64(jsonString);
    
    
    //清理符号
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"/" withString:@"-y"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"+" withString:@"-x"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@"-z"];
    
    
    /*
     * 第二次封装
     */
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionary];
    [requestDic2 setObject:jsonString forKey:@"parameters"];
    
    NSData *bodyData2 = [self toJSONData:requestDic2];
    jsonString = [[NSString alloc] initWithData:bodyData2
                                       encoding:NSUTF8StringEncoding];
    
    NSData *httpBodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return httpBodyData;
}


/**
 *  http请求公共方法（私有）
 *
 *  @param httpBodyData  post请求的body
 *  @param actionName    事件名称
 *  @param description   说明文字，用户调试使用
 *  @param success       block
 *  @param failure       block
 */

-(void)doHttpRequestWithHttpBody:(NSData *)httpBodyData Action:(NSString *)actionName Description:(NSString *)description success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    CLog(@"last url %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if (httpBodyData == nil) {
    }
    else
    {
        [request setHTTPBody:httpBodyData];
    }
    
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                    [self checkingIfLoginOnOtherDevice:dicty];
                }
            }
        }
    }];
}

//用于头像
-(void)doHttpRequestWithHttpBody:(NSData *)httpBodyData image:(NSData *)imageData Action:(NSString *)actionName Description:(NSString *)description success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    CLog(@"last url %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if (httpBodyData == nil) {
    }
    else
    {
        [request setHTTPBody:httpBodyData];
    }
    
    if (imageData == nil) {
    }
    else
    {
        [request setHTTPBody:imageData];
    }
    
    
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 接收到的数据：%@", description, receivedStr);
            //            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                    
                    [self checkingIfLoginOnOtherDevice:dicty];
                }
            }
        }
    }];
}


#pragma mark --------账号已经在另一台手机登录，需要强行退出，并清理本地用户信息 -----------
-(void)checkingIfLoginOnOtherDevice:(NSDictionary *)dicty
{
    //{"message":"帐号已经在其他地方登录，请重新登录！","code":3004}
    if([[dicty objectForKey:@"code"] integerValue] == 3004 &&
       [[dicty objectForKey:@"message"] isEqualToString:@"帐号已经在其他地方登录，请重新登录！"])
    {
        //设置登录状态
        [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HUD sharedHUDText] showForTime:2.0 WithText:@"您的账号已在其他设备登录"];
            

           /* UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"帐号已经在其他地方登录，请重新登录！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
            */
        });
    }
}


#pragma mark --------------- 手势解锁和加锁设置前的验证 --------------------------------

-(void)checkWhetherIsTheAdminUser:(NSString *)password success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"33/checkPassword"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:password forKey:@"pwd"];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"手势解锁和加锁设置前的验证"
                            success:success
                            failure:failure];
}



/**
 *  检查软件版本信息
 */
-(NSString *)checkingNewestVersion:(void (^)(id response))result
{
    //版本检测地址
#define APPVERSION_URL     [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=479149510"]
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:APPVERSION_URL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:20];
    [request setHTTPMethod:@"POST"]; //设置请求方式为POST，默认为GET
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!data) {
            CLog(@"失败:statusCode： %d", (int)[(NSHTTPURLResponse *)response statusCode]);
            result(nil);
        }
        else
        {
            //            NSString *str1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            NSDictionary *receivedDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
//            CLog(@"接收到的数据：%@,   response.statusCode = %i, Error = %@", receivedDictionary, (int)[(NSHTTPURLResponse *)response statusCode], connectionError.localizedDescription);
            
            NSArray *results = [receivedDictionary objectForKey:@"results"];
            if ([results count] > 0) {
                NSDictionary *firstResultDir = [results objectAtIndex:0];
                if(firstResultDir)
                {
                    NSString *versing = [firstResultDir objectForKey:@"version"];
                    if (versing)
                    {
                        result(versing);
                    }
                }
            }
            result(nil);
        }
    }];
    
    
    return nil;
}




























//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－
//下面是废弃的老接口－－－－－－－－－－－－－－－－－－－－－－－





//post类型的接口
-(void)NO_loginWithUID:(NSString *)tempUserId PWD:(NSString *)tempPassword Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString * actionName = @"login.action";
    
    CLog(@"用户名：%@, 密码：%@", tempUserId, tempPassword);
    
    tempUserId = [self base64encode:tempUserId];
    tempPassword = [self base64encode:tempPassword];
    
    
    
    // zxh start 改装成为post模式
    
    NSString *postBodyString = [NSString stringWithFormat:@"username=%@&password=%@", tempUserId, tempPassword];
    CLog(@"postBodyStr = %@", postBodyString);
    //UTF8转码
    postBodyString = [postBodyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyString);
    
    NSData *httpBodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"登录" success:success failure:failure];
    
    return;
    
    
    
    
    
    
    // zxh end
    
    
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@", MAIN_SERVER_REQUEST_INTERFACE, @"login.action"];
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];

    
    
    /**
     *  body & header
     */
    NSString *postBodyStr = [NSString stringWithFormat:@"username=%@&password=%@", tempUserId, tempPassword];
    CLog(@"postBodyStr = %@", postBodyStr);
    NSData *bodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [request setHTTPBody:bodyData];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //设置http-header:Content-Length
    
//    NSString *postLength = [NSString stringWithFormat:@"%ld",[bodyData length]];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"登录失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
//            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//            CLog(@"获取列表：%@", str1);
//            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
//
//            CLog(@"登录：  接收到的数据：%@   rrrr.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}



//get类型的接口
-(void)_loginWithUID:(NSString *)tempUserId PWD:(NSString *)tempPassword Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    CLog(@"%@, %@", tempUserId, tempPassword);
    
    //post数据  15528385682
//    NSString *tempUserId = [NSString stringWithFormat:@"15528385684"];//最为详细的账号：15528385684  123456
//    NSString *tempPassword = [NSString stringWithFormat:@"123456"];
    
    //编码
    tempUserId = [self base64encode:tempUserId];
    tempPassword = [self base64encode:tempPassword];
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?username=%@&password=%@", MAIN_SERVER_REQUEST_INTERFACE, @"login.action", tempUserId, tempPassword];
    
    CLog(@"whole URL %@  = ", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"登录失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取列表：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"登录：  接收到的数据：%@   rrrr.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


/**
 *  获取协议
 *
 *  @param agreementTypeName
 *  @param value
 *  @param success
 *  @param failure
 */
- (void)UnUSE_getAgreementWithAgreementType:(NSString *)value Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString * actionName = @"getAgreement.action";
    NSString *postBodyString = [NSString stringWithFormat:@"agreementType=%@", value];
    postBodyString = [postBodyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *httpBodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *description = [NSString stringWithFormat:@"获取协议: %@", @"REGISTRATION_AGREEMENT"];
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:description success:success failure:failure];
}



//http://182.92.217.163:8080/mobile/sendMobileRegisterCode.action?mobile=13618060758&mac=AXXXXXXXXXXXXXXXXX
/**
 *  注册第1步：注册账号时，获取验证码
 *
 *  @param mobileNumber
 *  @param sendMobileRegisterCode.action
 *  @param mac = B+UUID   (B表示iOS, UUID表示MAC地址)
 *  @param success
 *  @param failure
 */
-(void)NO_USED_requestVerifyCodeWithUID:(NSString *)mobileNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    CLog(@"mobileNumber = %@", mobileNumber);
    mobileNumber = [self base64encode:mobileNumber];
    CLog(@"加密 mobileNumber = %@", mobileNumber);
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
//    NSString * MACBase64 = [self base64encode:mac];
//    CLog(@"MACBase64 = %@", MACBase64);
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?mobile=%@&mac=%@",
                          MAIN_SERVER_REQUEST_INTERFACE,
                          @"sendMobileRegisterCode.action",
                          mobileNumber,
                          mac];
    
    CLog(@"whole URL %@", wholeURL);
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取验证码失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取验证码：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取验证码：  接收到的数据：%@   rrrr.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            
//            {"message":"发送成功","data":{"result":2000},"code":1000}
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}

-(void)checkingRegisterCode:(NSString *)smsCode phoneNumber:(NSString *)mobileNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    CLog(@"mobileNumber = %@", mobileNumber);
    mobileNumber = [self base64encode:mobileNumber];
    CLog(@"加密 mobileNumber = %@", mobileNumber);
    
    smsCode = [self base64encode:smsCode];
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
//    NSString * MACBase64 = [self base64encode:mac];
//    CLog(@"MACBase64 = %@", MACBase64);
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?mobile=%@&mac=%@&smsCode=%@",
                          MAIN_SERVER_REQUEST_INTERFACE,
                          @"checkMobileRegisterCode.action",
                          mobileNumber,
                          mac,
                          smsCode];
    
    CLog(@"whole URL %@", wholeURL);
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"验证验证码失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"验证验证码：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"验证验证码：  接收到的数据：%@   rrrr.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}

-(void)NOUSE_registerPassword:(NSString *)password phoneNumber:(NSString *)mobileNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    CLog(@"mobileNumber = %@", mobileNumber);
    mobileNumber = [self base64encode:mobileNumber];
    CLog(@"加密 mobileNumber = %@", mobileNumber);
    
    password = [self base64encode:password];
    
    NSString * mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?mobile=%@&mac=%@&password=%@",
                          MAIN_SERVER_REQUEST_INTERFACE,
                          @"register.action",
                          mobileNumber,
                          mac,
                          password];
    
    CLog(@"whole URL %@", wholeURL);
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"注册失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"注册：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"注册：  接收到的数据：%@   rrrr.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}



#pragma mark ---------------找回密码--------------------------------

-(void)findPWDForRequestVerifyCodeWithMobile:(NSString *)mobileNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"sendRetrievePwdForMobileCode.action";
    
    mobileNumber = [self base64encode:[NSString stringWithFormat:@"%@", mobileNumber]];
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
    
    NSString *postBodyStr = [NSString stringWithFormat:@"mobile=%@&mac=%@", mobileNumber, mac];
    
    CLog(@"postBodyStr %@", postBodyStr);
    
    //UTF8转码
    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"找回密码－请求验证码" success:success failure:failure];
}

-(void)findPWDForCheckingRegisterCode:(NSString *)smsCode phoneNumber:(NSString *)mobileNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"checkRetrievePwdForMobileCode.action";
    
    mobileNumber = [self base64encode:[NSString stringWithFormat:@"%@", mobileNumber]];
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
    
    smsCode = [self base64encode:[NSString stringWithFormat:@"%@", smsCode]];
    
    
    NSString *postBodyStr = [NSString stringWithFormat:@"mobile=%@&mac=%@&smsCode=%@", mobileNumber, mac, smsCode];
    
    
    CLog(@"postBodyStr %@", postBodyStr);
    
    //UTF8转码
    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"找回密码－验证验证码正确性" success:success failure:failure];
}

-(void)findPWDForResetPassword:(NSString *)password phoneNumber:(NSString *)mobileNumber autograph:(NSString *)autograph Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"resetPassword.action";
    
    mobileNumber = [self base64encode:[NSString stringWithFormat:@"%@", mobileNumber]];
    password = [self base64encode:[NSString stringWithFormat:@"%@", password]];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy#MM#dd HH*mm*ss";
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    currentDate = [self base64encode:[NSString stringWithFormat:@"%@", currentDate]];
    
    NSString *postBodyStr = [NSString stringWithFormat:@"mobile=%@&password=%@&autograph=%@", mobileNumber, password, currentDate];
    
    CLog(@"postBodyStr %@", postBodyStr);
    
    //UTF8转码
    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"找回密码－充值密码" success:success failure:failure];
}


#pragma mark --------------- 首页推荐项目 --------------------------------
//getTopLoans.action
//int topCount
-(void)requestTopLoanWith:(int)topCount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    
    NSString *actionName = @"getTopLoans.action";
    
//    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?topCount=%d", MAIN_SERVER_REQUEST_INTERFACE, actionName, 1];
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@", MAIN_SERVER_REQUEST_INTERFACE, actionName];
    
    CLog(@"首页推荐项目whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:20];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取首页推荐项目：%@", str1);
            
            
            CLog(@"获取首页推荐项目失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取首页推荐项目：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取首页推荐项目：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


#pragma mark --------------- 交易／投资记录列表界面 --------------------------------
/**
 *  交易投资记录－列表
 *
 *  @param productType DANBAO，RONGZI，BAOLI，QICHE
 *  @param pageIndex   第x页
 *  @param rowCount    每页默认为10条记录
 *  @param success
 *  @param failure
 */
//http://10.146.11.25:8080/mobile/getLoanLenderRecords.action?userId=6&productType=BAOLI&page=0&rows=10
//http://10.146.11.25:8080/mobile/getLoanLenderRecords.action?userId=6&productType=BAOLI&page=0&rows=10

/*
{
    code = 1000;
    data =     (
 {
 id = 3;
 interest = 3;
 lendAmount = 200;
 lendTime = "<null>";
 lenderId = "<null>";
 lenderName = "\U5f20\U9ebb\U5b50";
 loanId = 2;
 loanLenderId = 0;
 loanLenderRecordPayStatusString = "<null>";
 loanLenderRecordStatusString = "<null>";
 loanLenderStatusValue = "\U62db\U6807\U4e2d";
 loanMonthsValue = 1;
 loanTitle = "\U70d8\U7119\U98df\U54c1";
 loanTypeValue = "\U4e2a\U4eba\U501f\U6b3e";
 productId = 0;
 productName = "<null>";
 },
 {
 id = 2;
 interest = 3;
 lendAmount = 200;
 lendTime = "<null>";
 lenderId = "<null>";
 lenderName = "\U5f20\U9ebb\U5b50";
 loanId = 2;
 loanLenderId = 0;
 loanLenderRecordPayStatusString = "<null>";
 loanLenderRecordStatusString = "<null>";
 loanLenderStatusValue = "\U62db\U6807\U4e2d";
 loanMonthsValue = 1;
 loanTitle = "\U70d8\U7119\U98df\U54c1";
 loanTypeValue = "\U4e2a\U4eba\U501f\U6b3e";
 productId = 0;
 productName = "<null>";
 }
    );
    message = "<null>";
}
 
 {
 "id":3,
 "loanId":2,
 "loanTitle":"烘焙食品",
 "lenderId":null,
 "loanTypeValue":"个人借款",
 "loanMonthsValue":"1",
 "loanLenderStatusValue":"招标中",
 "lenderName":"张麻子",
 "lendAmount":200.0,
 "interest":3.0,
 "loanLenderRecordStatusString":null,
 "lendTime":null,
 "loanLenderId":0,
 "loanLenderRecordPayStatusString":null,
 "productId":0,
 "productName":null
 },
 {
 "id":2,"loanId":2,
 "loanTitle":"烘焙食品",
 "lenderId":null,
 "loanTypeValue":"个人借款",
 "loanMonthsValue":"1",
 "loanLenderStatusValue":"招标中",
 "lenderName":"张麻子",
 "lendAmount":200.0,
 "interest":3.0,
 "loanLenderRecordStatusString":null,
 "lendTime":null,
 "loanLenderId":0,
 "loanLenderRecordPayStatusString":null,
 "productId":0,
 "productName":null
 },
 {"id":1,"loanId":1,"loanTitle":"烘焙食品","lenderId":null,"loanTypeValue":"个人借款","loanMonthsValue":"1","loanLenderStatusValue":"招标中","lenderName":"张麻子","lendAmount":11.0,"interest":3.0,"loanLenderRecordStatusString":null,"lendTime":null,"loanLenderId":0,"loanLenderRecordPayStatusString":null,"productId":0,"productName":null}
*/

-(void)requestLoanLenderListWithProductType:(NSString *)productType userId:(int)userid page:(NSInteger)pageIndex rowCount:(NSInteger)rowCount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *tempUserId = [NSString stringWithFormat:@"%d",userid];
    
    NSString *actionName = @"getLoanLenderRecords.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%@&productType=%@&page=%ld&rows=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          tempUserId, productType,(long)pageIndex, (long)rowCount];
    CLog(@"交易／投资记录whole URL %@", wholeURL);
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取交易／投资记录列表失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取交易／投资记录列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取交易／投资记录列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}



///**
// * 获取交易记录的明细列表
// */
// id
// getLoanPharsesById.action
- (void)requestPaymentRecordById:(NSInteger)loanPharsesId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"getLoanPharsesById.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?id=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName, loanPharsesId];
    
    CLog(@"获取用户回款 详细记录列表 whole URL %@", wholeURL);
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取用户回款 详细记录列表：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//            CLog(@"获取用户回款 详细记录列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取用户回款 详细记录列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
    
}







#pragma mark --------------- 消息列表 --------------------------------
//http://localhost:8080/mobile/getMessageInfos.action?userId=6&page=0&rows=10

//{"message":null,"data":{"content":"你的消息内容","id":1,"title":"你的消息title","hasRead":false,"sendTime":1417555613000},"code":1000}

-(void)requestMessageInfoWithPage:(NSInteger)pageIndex rowCount:(NSInteger)rowCount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    NSString *actionName = @"getMessageInfos.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld&page=%ld&rows=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          tempUserId, pageIndex, rowCount];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取消息列表失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取消息列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取消息列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];

}

//消息已经查看
-(void)setMessageReadWithMessageID:(NSInteger)msgId userId:(NSInteger)userId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    CLog(@"消息列表 tempUserId = %ld", tempUserId);//76
    
    NSString *actionName = @"setMessageRead.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld&id=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          tempUserId, msgId];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];   //设置请求方式为POST，默认为GET
    
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"设置消息已读失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"设置消息已读：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"设置消息已读  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}

//删除消息
-(void)deleteMessagesWithMessageIDs:(NSArray *)msgIds userId:(NSInteger)userId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    CLog(@"删除 tempUserId = %ld", tempUserId);
    
    NSString *actionName = @"setMessageDeleted.action";

    NSString *msgIds_str = @"";
    
    CLog(@"msgIds = %@", msgIds);
    
    for (int i = 0; i < [msgIds count]; i++) {
        
        NSNumber *msgId = [msgIds objectAtIndex:i];
        
        if (i == [msgIds count] - 1) {
            msgIds_str = [msgIds_str stringByAppendingFormat:@"%ld", msgId.integerValue];
        }
        else
        {
            msgIds_str = [msgIds_str stringByAppendingFormat:@"%ld,", msgId.integerValue];
        }
    }
    
    CLog(@"msgIds_str = %@", msgIds_str);
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld&ids=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, tempUserId, msgIds_str];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"删除失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"删除消息：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"删除消息  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000) {
                success(dicty);
                //删除消息成功：{"data":{"result":2000},"code":1000}
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


#pragma mark --------------- 银行卡列表 --------------------------------
//http://localhost:8080/mobile/getUserBanks.action?userId=6
/*{
 "message":null,
 "data":{
     "username":null,
     "cardNumber":"6227003811890272891"
     },
 "code":1000
 }*/

-(void)requestUserBankListSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    NSString *actionName = @"getUserBanks.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName, tempUserId];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取银行卡列表失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取银行卡列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取银行卡列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


//支持的银行卡类型
-(void)requestSupportedBankListSuccess:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"getBanks.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@", MAIN_SERVER_REQUEST_INTERFACE, actionName];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取支持的银行失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取支持的银行：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取支持的银行：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}

//添加银行卡
//user.id ＝ userId
//cardNumber
//bank.id
//username (开户姓名)
//addUserBank.action

-(void)addNewBankCardWithUserName:(NSString *)username cardNumber:(NSString *)cardNumber bankTypeId:(NSInteger)bankTypeId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    NSString *actionName = @"addUserBank.action";
    
    
//    
//    // zxh start 改装成为post模式

    
//    username =  [username stringByAddingPercentEscapesUsingEncoding:NSUnicodeStringEncoding];
//    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)username, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    NSString *postBodyStr = [NSString stringWithFormat:@"user.id=%ld&cardNumber=%@&bank.id=%ld&username=%@", tempUserId, cardNumber, bankTypeId, username];

    CLog(@"postBodyStr %@", postBodyStr);
    
//    postBodyStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                   (CFStringRef)postBodyStr,
//                                                                                   NULL,
//                                                                                   NULL,
//                                                                                   kCFStringEncodingUTF8));
    
    
    //UTF8转码
//    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUnicodeStringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"添加银行卡"
                         returnType:ReturnTypeSameLevel
                            success:success
                            failure:failure];
    
    return;
    
//    // zxh end
    
    
    
    
    
//    username =  [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)username, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?user.id=%ld&cardNumber=%@&bank.id=%ld&username=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, tempUserId, cardNumber, bankTypeId, username];
    
    CLog(@"whole URL %@", wholeURL);
    
    //UTF8转码
//    wholeURL = [wholeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    CLog(@"encoded whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"添加银行失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"添加银行银行：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"添加银行银行：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
//                {"result":2001,"data":null,"code":1001}
                
                failure(dicty);
            }
        }
    }];
}


//id  （银行卡的id由getUserBanks.action方法获得）
//unbindUserBank.action
-(void)deleteUserBankWithCardId:(NSInteger)cardId Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"unbindUserBank.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?id=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,  cardId];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"删除银行卡失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"绑定银行卡列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"绑定银行卡列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];

}

//userId
//cardNumber
//setDefaultBank.action
-(void)bindUserBankWithBankNumber:(NSString *)cardNumber Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    NSString *actionName = @"setDefaultBank.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld&cardNumber=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, tempUserId, cardNumber];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"绑定银行卡失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"绑定银行卡列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"绑定银行卡列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}



#pragma mark --------------- 获取奖励积分列表 --------------------------------

//getAwardRecords.action
//userId
//page
//rows
//http://10.146.11.25:8080/mobile/getAwardRecords.action?userId=6&page=0&rows=100

-(void)requestAwardRecordsListWithPage:(NSInteger)pageIndex rowCount:(NSInteger)rowCount Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    
    NSString *actionName = @"getAwardRecords.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%ld&page=%ld&rows=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          tempUserId, pageIndex, rowCount];
    
    CLog(@"whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取奖励积分列表失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取奖励积分列表：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取奖励积分列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}




#pragma mark --------------- 刷新单个项目cell --------------------------------
-(void)requestSingleProductByLoanId:(NSInteger)loanId success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"refreshLoan.action";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    [requestDic setObject:[NSNumber numberWithInteger:loanId] forKey:@"id"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"刷新单个的cell"
                            success:success
                            failure:failure];
    
    
//    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"请求单条产品数据" success:success failure:failure];
//    [self doHttpRequestWithHttpBody:[] Action:actionName Description:@"请求单条产品数据" returnType:ReturnTypeOnlyCode success:success failure:failure];
}


#pragma mark --------------- 产品列表 --------------------------------
//getProductList.action
//count
//start == page
//productType

//loanType：DANBAO，RONGZI，BAOLI，QICHE
//现有接口
-(void)requestProductListWithStart:(NSInteger)pageIndex
                          rowCount:(NSInteger)count
                          loanType:(NSString *)loanType
                           success:(void(^)(id response))success
                           failure:(void(^)(id response))failure
{
    NSString *actionName = @"getProductList.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?rows=%ld&page=%ld&productType=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, count, pageIndex, loanType];
    
    CLog(@"获取产品列表 whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取产品列表：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取产品列表自然数据：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
//            CLog(@"获取产品列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得产品列表:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}

//标准接口
-(void)requestProductListWithProductId:(NSInteger)productId
                              pullFlag:(NSInteger)pullFlag
                              loanType:(NSString *)loanType
                              rowCount:(NSInteger)count
                               success:(void(^)(id response))success
                               failure:(void(^)(id response))failure
{
    NSString *actionName = @"getProductList.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?start=%ld&pullFlag=%ld&loanType=%@&count=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName, productId, pullFlag, loanType, count];
    
    CLog(@"获取产品列表 whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"获取产品列表：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"获取产品列表自然数据：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"获取产品列表：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}




#pragma mark --------------- 产品更多详情 --------------------------------
//getLoanInfo.action
//loanId=5
-(void)requestMoreLoanInfoWithLoanId:(NSInteger)loanId
                            loanType:(NSString *)loanType
                             success:(void(^)(id response))success
                             failure:(void(^)(id response))failure
{
    NSString *actionName = @"getLoanInfo.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?loanId=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          loanId];
    
    CLog(@"产品更多详情whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"产品更多详情失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"产品更多详情：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"产品更多详情：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


#pragma mark --------------- 单个产品投资记录 --------------------------------
//getLoanRecordById.action
//loanId, count
-(void)requestRecordListOfLoanWithLoanId:(NSInteger)loanId
                                loanType:(NSString *)loanType
                                rowCount:(NSInteger)count
                                 success:(void(^)(id response))success
                                 failure:(void(^)(id response))failure
{
    NSString *actionName = @"getLoanRecordById.action";
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?loanId=%ld&count=%ld", MAIN_SERVER_REQUEST_INTERFACE, actionName,
                          loanId, count];
    
    //标准
//    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?loanId=%ld&count=%ld&loanType=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName,
//                          loanId, count, loanType];
    
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];   //设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"产品更多详情失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
//            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//            CLog(@"单个产品投资记录：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
//            CLog(@"单个产品投资记录：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //取得系统Session:
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}



#pragma mark --------------- 安全设置接口 --------------------------------

//手机认证,获取短信验证码
//sendBindMobilephoneCode.action
//String mobile （base64）
-(void)bindMobile:(NSString *)mobileNum success:(void(^)(id response))success
          failure:(void(^)(id response))failure
{
    NSString *actionName = @"sendBindMobilephoneCode.action";
    
    /**
     *  mobile Number
     */
    mobileNum = [self base64encode:mobileNum];
    
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?mobile=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, mobileNum];
    
    CLog(@"手机认证whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"手机认证失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
//            手机认证：{"message":"电话号码已经被其他用户认证","data":{"result":2001},"code":1000}
//            有机认证，手机号不存在，可以进行认证：{"message":null,"data":{"result":2000},"code":1000}
            
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"手机认证：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            CLog(@"手机认证：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2001) {
                failure(dicty);
            }
            else if([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                    [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
            {
                success(dicty);
            }
        }
    }];
}

//验证码短信，确认反馈
//updateBindMobilephone.action
//String userId, String smsCode, String mobile （全部数据 base 64）
-(void)confirmBindMobile:(NSString *)mobileNum verifyCode:(NSString *)smsCode success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"updateBindMobilephone.action";
    
    /**
     *  mobile Number
     */
    mobileNum = [self base64encode:mobileNum];
    
    /**
     *  sms Code
     */
    smsCode = [self base64encode:smsCode];
    
    /**
     *  user id
     */
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    NSString *userIdStr = [self base64encode:[NSString stringWithFormat:@"%ld", tempUserId]];
    
    
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?mobile=%@&smsCode=%@&userId=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, mobileNum, smsCode, userIdStr];
    
    CLog(@"手机验证码 确认：whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"手机验证码 认证失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"手机验证码 认证：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"手机验证码 认证：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
//            {"data":{"result":2000},"code":1000}
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}




//昵称认证
//setUserNickName.action
//String userId, String nickName

-(void)setNikeName:(NSString *)nikeName success:(void(^)(id response))success
           failure:(void(^)(id response))failure
{
    //
    NSString *actionName = @"setUserNickName.action";
    
    //
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    CLog(@"User Id = %ld", tempUserId);
    NSString *userIdStr = [self base64encode:[NSString stringWithFormat:@"%ld", tempUserId]];
    CLog(@"base64 User Id = %@", userIdStr);
    
    CLog(@"nikeName %@", nikeName);
    nikeName = [self base64encode:nikeName];
    CLog(@"base64 nikeName %@", nikeName);
    
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%@&nickName=%@", MAIN_SERVER_REQUEST_INTERFACE, actionName, userIdStr, nikeName];
    
    CLog(@"昵称认证 whole URL %@", wholeURL);
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    
    //连接服务器
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"昵称认证失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"昵称认证：%@", str1);
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"昵称认证：  接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            //成功{"data":{"result":2000},"code":1000}
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
}


#pragma mark --------------- 充值 提现 --------------------------------


/**
 *  充值
 *
 *  @param NSString userId     用户id
 *  @param NSString amount  充值金额
 *  @param NSString mac        mac地址
 *
 *  @return
 */
-(void)rechargeMoney:(float)moneySum success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"recharge.action";
    
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    
    NSString *userIdStr = [self base64encode:[NSString stringWithFormat:@"%ld", tempUserId]];
    
    NSString *amount = [self base64encode:[NSString stringWithFormat:@"%f", moneySum]];
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
    
    NSString *postBodyStr = [NSString stringWithFormat:@"userId=%@&amount=%@&mac=%@", userIdStr, amount, mac];
    
    CLog(@"postBodyStr %@", postBodyStr);
    
    //UTF8转码
    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"充值" success:success failure:failure];
    
    
    return;
    
    
    
    
    /*
    
    NSMutableURLRequest *request;
    
    if (POST_MODE) {
        NSString *wholeURL = [NSString stringWithFormat:@"%@%@", MAIN_SERVER_REQUEST_INTERFACE, actionName];
        NSURL *url = [NSURL URLWithString:wholeURL];
        request = [[NSMutableURLRequest alloc]initWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:requestInterval];
        [request setHTTPMethod:@"POST"];
        
        NSString *postBodyStr = [NSString stringWithFormat:@"userId=%@&money=%f", userIdStr, moneySum];
        CLog(@"postBodyStr = %@", postBodyStr);
        NSData *bodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPBody:bodyData];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    else
    {
        NSString *wholeURL = [NSString stringWithFormat:@"%@%@?userId=%@&money=%f", MAIN_SERVER_REQUEST_INTERFACE, actionName, userIdStr, moneySum];
        
        CLog(@"充值 whole URL %@", wholeURL);
        
        NSURL *url = [NSURL URLWithString:wholeURL];
        request = [[NSMutableURLRequest alloc]initWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:requestInterval];
        [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    }
    
    
    
//    [self doHttpRequest:request success:success failure:failure];
    
    */
    
    //连接服务器
    /*
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"充值失败：  statusCode： %d",(int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"充值：%@", str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"充值接收到的数据：%@   response.statusCode = %d", dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000) {
                success(dicty);
            }
            else
            {
                failure(dicty);
            }
        }
    }];
     */
}


/**
 *  提现
 *
 *  @param NSString
 *
 *  @return
 */
-(void)extractionMoney:(float)moneySum toBankCardId:(NSInteger)bankCardId success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *actionName = @"mentionNowInfo.action";
    
    NSInteger tempUserId = -1;
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
    }
    NSString *userIdStr = [self base64encode:[NSString stringWithFormat:@"%ld", (long)tempUserId]];
    
    NSString *amount = [self base64encode:[NSString stringWithFormat:@"%f", moneySum]];
    
    NSString *bankCardIdEncode = [self base64encode:[NSString stringWithFormat:@"%ld", (long)bankCardId]];
    
    NSString *mac = [NSString stringWithFormat:@"B%@", [self getCurrentDeviceUUID]];
    
    NSString *postBodyStr = [NSString stringWithFormat:@"userId=%@&amount=%@&bankId=%@&mac=%@", userIdStr, amount, bankCardIdEncode, mac];
    
    CLog(@"提现 postBodyStr %@", postBodyStr);
    
    //UTF8转码
    postBodyStr = [postBodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLog(@"UTF8 postBodyStr %@", postBodyStr);
    
    
    NSData *httpBodyData = [postBodyStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self doHttpRequestWithHttpBody:httpBodyData Action:actionName Description:@"提现" success:success failure:failure];
}







#pragma Mark   -------------  http request 公共  ----------------

/**
 *  http请求公共方法（返回字段code和result在同一层级）
 *
 *  @param httpBodyData  post请求的body
 *  @param actionName    事件名称
 *  @param description   说明文字，用户调试使用
 *  @param type          返回数据的类型
 *  @param success       block
 *  @param failure       block
 */
-(void)doHttpRequestWithHttpBody:(NSData *)httpBodyData Action:(NSString *)actionName Description:(NSString *)description returnType:(returnSuccessType)type success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString *wholeURL = [NSString stringWithFormat:@"%@%@", MAIN_SERVER_REQUEST_INTERFACE, actionName];
    
    NSURL *url = [NSURL URLWithString:wholeURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:httpBodyData];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            CLog(@"%@：%@", description, str1);
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            
            
            if (ReturnTypeSameLevel == type) {
                if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                    [[dicty objectForKey:@"result"] integerValue] == 2000)
                {
                    success(dicty);
                }
                else
                {
                    failure(dicty);
                }
            }
            else if (ReturnTypeOnlyCode == type)
            {
                if ([[dicty objectForKey:@"code"] integerValue] == 1000)
                {
                    success(dicty);
                }
                else
                {
                    failure(dicty);
                }
            }
            else //ReturnTypeNormal
            {
                if ([[dicty objectForKey:@"code"] integerValue] == 1000 &&
                    [[[dicty objectForKey:@"data"] objectForKey:@"result"] integerValue] == 2000)
                {
                    success(dicty);
                }
                else
                {
                    failure(dicty);
                }
            }
        }
    }];
}

#pragma mark ---------------  发现界面请求 --------------------------------
//发现用户反馈界面请求
-(void)SendiDearsWith:(NSString*)userIdear Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    
//    NSDictionary* dic = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLocalUserIdAndPassword];
//    NSString* userid  = [dic objectForKey:@"admin_user_id_key"];
//    
//    
//    NSString *actionName = [NSString stringWithFormat:@"70/subUserSugges"];
//    NSDictionary* requestDic = [[NSDictionary alloc] initWithObjectsAndKeys:userid,@"loginKey",userIdear,@"userSugges", nil];
//    
//    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
//                             Action:actionName
//                        Description:@"用户意见反馈"
//                            success:success
//                            failure:failure];
    
    NSString *actionName = @"70/subUserSugges";
//    [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey]
    
    
    NSDictionary* requestDic = [[NSDictionary alloc] initWithObjectsAndKeys: userIdear,@"userSugges",[[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey],@"loginKey",nil];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>项目详细信息", @"loginKey"]
                            success:success
                            failure:failure];

    
}

-(void)getBankListWithCityCode:(NSString*)Citycode CardNum:(NSString*)Cardcode Success:(void(^)(id response))success failure:(void(^)(id response))failure{
    
    NSString *actionName = @"88/banklists";
    //    [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey]
    
    
    NSDictionary* requestDic = [[NSDictionary alloc] initWithObjectsAndKeys: Citycode,@"cityCode",Cardcode,@"cardNo",nil];
    
    
    NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
    
    CLog(@"last url %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
//            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                success(dicty);
            }
        }
    }];
    
    
//    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
//                             Action:actionName
//                        Description:[NSString stringWithFormat:@"获取<%@>项目详细信息", @"loginKey"]
//                            success:success
//                            failure:failure];
}

-(void)SendiUserIconWithUserIcon:(UIImage*)img Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    
      NSString *actionName = @"71/uHeadImgInfo";
    //    [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey]
    
    NSData *imageData = UIImageJPEGRepresentation(img, 0.05);
    NSString *imageBase = [imageData base64Encoding];
    NSDictionary * requestDic = [[NSDictionary alloc] initWithObjectsAndKeys:[[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey],@"loginKey", imageBase,@"headImage",nil];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>项目详细信息", @"loginKey"]
                            success:success
                            failure:failure];
    
    
}

-(void)getUrlByType:(NSString*)type Success:(void(^)(id response))success failure:(void(^)(id response))failure{
    NSString *actionName = @"72/staticpage";
    //    [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey]
    
    
    NSDictionary* requestDic = [[NSDictionary alloc] initWithObjectsAndKeys: type,@"pageType",nil];
    
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:[NSString stringWithFormat:@"获取<%@>项目详细信息", @"loginKey"]
                            success:success
                            failure:failure];
}

#pragma mark -------------------------红包奖励---------------------------------

-(void)getUserLoginKey:(NSString *)loginKey  Page:(NSInteger)page Rows:(NSInteger)rows ActiveType:(NSString *)activeType Success:(void (^)(id response))success failure:(void (^)(id response))failure
{

    NSString  *actionName = @"74/list";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    
    [requestDic addEntriesFromDictionary:[self commonBean]];
//    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [requestDic setObject:[NSString stringWithFormat:@"%ld",(long)rows] forKey:@"rows"];
    [requestDic setObject:activeType forKey:@"activeType"];
    
//    NSInteger tempUserId = -1;
//    if([[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn]){
//        tempUserId = [ZMAdminUserStatusModel shareAdminUserStatusModel].userId;
//    }
    
    NSString *str = [NSString stringWithFormat:@"%@?loginKey=%@&activeCode=HONGBAOAWARD&page=%ld&rows=%ld", SERVER_REQUEST_INTERFACE(actionName),loginKey,(long)page,(long)rows];
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    NSString *description = @"获取我的奖励信息";
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
                success(dicty);
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];
}

-(void)getUserRedPackWithLoginKey:(NSString *)loginKey Page:(NSInteger)page Rows:(NSInteger)rows Success:(void(^)(id response))success failure:(void(^)(id response))failure
{
    NSString  *actionName = @"75/list";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    
    [requestDic addEntriesFromDictionary:[self commonBean]];
    //    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [requestDic setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    [requestDic setObject:[NSString stringWithFormat:@"%ld",(long)rows] forKey:@"rows"];
    
    NSString *str = [NSString stringWithFormat:@"%@?loginKey=%@&page=%ld&rows=%ld", SERVER_REQUEST_INTERFACE(actionName),loginKey,(long)page,(long)rows];
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    NSString *description = @"获取我的红包信息";
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            success(dicty);
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];

}

//首次充值
- (void)FirstRechargeSuccess:(void (^)(id response))success failure:(void (^)(id response))failure
{
    NSString *actionName = [NSString stringWithFormat:@"76"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    //    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
    //                             Action:actionName
    //                        Description:@"是否首次充值"
    //                            success:success
    //                            failure:failure];
    NSString *str = [NSString stringWithFormat:@"%@?loginKey=%@", SERVER_REQUEST_INTERFACE(actionName),loginKey];
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    NSString *description = @"是否首次充值";
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            success(dicty);
            
        }
    }];
}


-(void)getUserNowSuccess:(void (^)(id response))success failure:(void (^)(id response))failure
{
    
    NSString *actionName = [NSString stringWithFormat:@"34/messagePrompt/ios"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    [requestDic setObject:version forKey:@"version"];
    
    NSString *str = [NSString stringWithFormat:@"%@", SERVER_REQUEST_INTERFACE(actionName)];
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:requestInterval];
    [request setHTTPMethod:@"POST"];
    
    if ([self packageTheRequestData:requestDic] == nil) {
    }
    else
    {
        [request setHTTPBody:[self packageTheRequestData:requestDic]];
    }
    
    NSString *description = @"关于财行家";
    
    [request setValue:@"application/json;charset=utf-8;x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainCurrentQueue completionHandler:^(NSURLResponse *response, NSData *received, NSError *connectionError) {
        if (!received) {
            CLog(@"%@失败：  statusCode： %d", description, (int)[(NSHTTPURLResponse *)response statusCode]);
            failure(nil);
        }
        else
        {
            NSString *receivedStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            
            NSDictionary *dicty = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            
            CLog(@"%@ 1接收到的数据：%@", description, receivedStr);
            CLog(@"%@ 2接收到的数据：%@   response.statusCode = %d", description ,dicty, (int)[(NSHTTPURLResponse *)response statusCode]);
            success(dicty);
            if ([[dicty objectForKey:@"code"] integerValue] == 1000) {
                success(dicty);
            }
            else
            {
                //已经被另一台设备登陆
                if ([[dicty objectForKey:@"code"] integerValue] == 4003 && [[dicty objectForKey:@"message"] isEqualToString:@"请先登录"])
                {
                    //已经退出登陆了
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
                }
                else{
                    failure(dicty);
                }
            }
        }
    }];


}


//获取邀请链接
- (void)RequestInviteFriendsUrlSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *actionName = [NSString stringWithFormat:@"73/usersharecodelist"];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:[self commonBean]];
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    [requestDic setObject:loginKey forKey:@"loginKey"];
    [self doHttpRequestWithHttpBody:[self packageTheRequestData:requestDic]
                             Action:actionName
                        Description:@"获取邀请链接"
                            success:success
                            failure:failure];
}

@end
