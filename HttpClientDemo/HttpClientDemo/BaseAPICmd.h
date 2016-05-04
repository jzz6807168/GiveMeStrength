//
//  BaseAPICmd.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

/*
 每一个API需要建一个类 如：LoginAPICmd，遵守协议 BaseAPICmdDelegate并实现协议，决定该请求的方式：
 
 - (BaseAPICmdRequestType)requestType
 {
     return BaseAPICmdRequestTypePost;
 }
 - (NSString *)apiCmdDescription
 {
     return @"对该API功能的描述";
 }
 ---------------------------------------------------------------------------------
                                 设置API以及参数
 ---------------------------------------------------------------------------------
 使用之前需要设置path（API）和reformParams（参数）：
 
 loginAPICmd.path = @"/usernew/ajaxLogin";
 loginAPICmd.reformParams = [NSDictionary dictionaryWithObjectsAndKeys:name, @"username", @"qwer1234", @"password", @"123456", nil];
 
 持有者实现 APICmdApiCallBackDelegate
 loginAPICmd.delegate = self;
 ---------------------------------------------------------------------------------
                                  开始请求数据
 ---------------------------------------------------------------------------------
 开始请求数据：
 [[APIManager manager] performCmd:loginAPICmd];
     或者
 [loginAPICmd loadData]（推荐使用）;
 
 均可
 ---------------------------------------------------------------------------------
                                    数据回调
 ---------------------------------------------------------------------------------
 数据回调  同一类多个请求 请判断baseAPICmd
 - (void)apiCmdDidSuccess:(BaseAPICmd *)baseAPICmd responseData:(NSDictionary *)responseData
 {
     if (baseAPICmd == loginAPICmd) {
 
     }
 
     或者
     if ([baseAPICmd isKindOfClass:[loginAPICmd class]]) {
 
     }
     都可以
 }
 ---------------------------------------------------------------------------------
                                    拦截器
 ---------------------------------------------------------------------------------
 APICmdInterceptor 用于拦截网络数据的回调
 //开始请求数据
 - (void)apiCmdStartLoadData:(BaseAPICmd *)apiCmd;
 // 数据请求成功回调之前
 - (void)apiCmd:(BaseAPICmd *)apiCmd beforePerformSuccessWithResponse:(NSURLResponse *)response;
 // 数据请求成功回调之后
 - (void)apiCmd:(BaseAPICmd *)apiCmd afterPerformSuccessWithResponse:(NSURLResponse *)response;
 // 数据请求失败回调之前
 - (void)apiCmd:(BaseAPICmd *)apiCmd beforePerformFailWithResponse:(NSURLResponse *)response;
 // 数据请求失败回调之后
 - (void)apiCmd:(BaseAPICmd *)apiCmd afterPerformFailWithResponse:(NSURLResponse *)response;
 // 请求参数 验证参数
 - (BOOL)apiCmd:(BaseAPICmd *)apiCmd shouldCallAPIWithParams:(NSDictionary *)params;
 // 请求参数之后
 - (void)apiCmd:(BaseAPICmd *)apiCmd afterCallingAPIWithParams:(NSDictionary *)params;
 
 使用方法：重载 APICmd 的 init 方法
 - (instancetype)init
 {
     self = [super init];
     if (self) {
         //设置代理
         self.interceptor = self;
     }
     return self;
 }
 
 也可以在controller里面设置
 ---------------------------------------------------------------------------------
                              查询当前API的请求状态
 ---------------------------------------------------------------------------------
 查询当前API是否在loading：
 [[APIManager manager] isLoadingWithRequestID:loginAPICmd.requestId];
 或
 loginAPICmd.isLoading(推荐使用)
 
 取消当前的请求：
 [[APIManager manager] cancelRequestWithRequestID:loginAPICmd.requestId];
 或
 [loginAPICmd cancelRequest]; (推荐使用)
 （默认API 调用dealloc 时  取消当前请求）
 
 ---------------------------------------------------------------------------------
                                    Warning
 ---------------------------------------------------------------------------------
 1.尽量少使用 APIManager 以防发生不必要的错误（除cancelAllRequest方法）
 2.禁止重载 BaseAPICmd 里的方法
 */


#import <Foundation/Foundation.h>
#import "URLResponse.h"

@class BaseAPICmd;
typedef NS_ENUM (NSUInteger, BaseAPICmdRequestType){
    BaseAPICmdRequestTypeGet,
    BaseAPICmdRequestTypePost,
    BaseAPICmdRequestTypeGetNormal,
    BaseAPICmdRequestTypePostNormal,
};

typedef NS_ENUM (NSUInteger, BaseAPICmdErrorType){
    BaseAPICmdErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    BaseAPICmdErrorTypeTimeout,       //请求超时。设置的是20秒超时。
    BaseAPICmdErrorTypeNoNetWork,     //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    APIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
};

/*************************************************************************************************/
/*                                           APIManager                                          */
/*************************************************************************************************/
/*
 BaseAPICmd的派生类必须符合这些protocal
 */
@protocol BaseAPICmdDelegate <NSObject>
@required
//返回请求的类型
- (BaseAPICmdRequestType)requestType;
@optional
- (NSString *)apiCmdDescription;
- (NSString *)methodName;
- (NSString *)serviceType;
- (BOOL)isCancelRequest;
- (BOOL)isRequestHook;
//验证返回的数据格式是否正确
- (id)jsonValidator;
@end

/*************************************************************************************************/
/*                               APIManagerApiCallBackDelegate                                   */
/*************************************************************************************************/
//api回调 返回数据，由controller或者持有者实现
@protocol APICmdApiCallBackDelegate <NSObject>
@required

- (void)apiCmdDidSuccess:(BaseAPICmd *)baseAPICmd responseData:(id)responseData;
- (void)apiCmdDidFailed:(BaseAPICmd *)baseAPICmd error:(NSError *)error;
@optional
- (void)apiCmdDidSuccess:(BaseAPICmd *)baseAPICmd response:(URLResponse *)response;
- (void)apiCmdDidFailed:(BaseAPICmd *)baseAPICmd errorType:(BaseAPICmdErrorType)errorType;
@end

/*************************************************************************************************/
/*                               APICmdParamSourceDelegate                                       */
/*************************************************************************************************/
/*  获取 请求的参数写法  路径参数 ||
 *  路径参数 " ||xxx " ：
 *  如 api_v2/FundProduct/{fundProductId}/ExtAttribute
 *  在XXXAPICmd 中 "- (NSString *)methodName" 的返回值 为：api_v2/FundProduct/||fundProductId/ExtAttribute
 *  请求格式 @{@"||fundProductId":@"ueoieu642837425234"}
 *
 *  如果请求为POST API 和 上传中都有参数， API中的参数：路径参数同上   body参数前加":"，如：
 *  api_v2/FundProduct/{fundProductId}/ExtAttribute
 *  请求格式：@{@"||fundProductId":@"ueoieu642837425234", //路径参数
 *                @":isCustomer":@(YES),                //POST body参数参数
 *     @":customerCompanyInfoId":@"ueoieu642837425234", //POST body参数参数
 *         @"DownloadMaterialId":@"ueoieu642837425234", //一般URL参数
 *               @"MaterialName":@"xxxfile.docx"}       //一般URL参数
 *
 *  上传的数据为数组 则使用“kReformParamArray”作为key
 */
@protocol APICmdParamSourceDelegate <NSObject>
@required
- (NSDictionary *)paramsForApi:(BaseAPICmd *)apiCmd;
@end

/*************************************************************************************************/
/*                                    APIManagerInterceptor                                      */
/*************************************************************************************************/
/*
 APIBaseManager的派生类必须符合这些protocal
 拦截器
 
 */
@protocol APICmdInterceptor <NSObject>

@optional

- (void)apiCmdStartLoadData:(BaseAPICmd *)apiCmd;

- (void)apiCmd:(BaseAPICmd *)apiCmd beforePerformSuccessWithResponse:(URLResponse *)response;
- (void)apiCmd:(BaseAPICmd *)apiCmd afterPerformSuccessWithResponse:(URLResponse *)response;

- (void)apiCmd:(BaseAPICmd *)apiCmd beforePerformFailWithResponse:(URLResponse *)response;
- (void)apiCmd:(BaseAPICmd *)apiCmd afterPerformFailWithResponse:(URLResponse *)response;

- (BOOL)apiCmd:(BaseAPICmd *)apiCmd shouldCallAPIWithParams:(NSDictionary *)params;
- (void)apiCmd:(BaseAPICmd *)apiCmd afterCallingAPIWithParams:(NSDictionary *)params;

@end

/*************************************************************************************************/
/*                                 APIManagerCallbackDataReformer                                */
/*************************************************************************************************/
// 拦截器
@protocol APICmdAspect <NSObject>
@optional
- (void)apiCmd:(BaseAPICmd *)apiCmd request:(NSMutableURLRequest *)request;
@end


@interface BaseAPICmd : NSObject

@property (nonatomic, weak) NSObject<BaseAPICmdDelegate>  *child;
@property (nonatomic, weak) id<APICmdApiCallBackDelegate>   delegate;
@property (nonatomic, weak) id<APICmdInterceptor>           interceptor;
@property (nonatomic, weak) id<APICmdParamSourceDelegate>   paramSource;
@property (nonatomic, weak) id<APICmdAspect>                aspect;


@property (nonatomic, copy) id reformParams;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, readonly, assign) NSInteger requestId;
@property (nonatomic, readonly, copy) NSString *absouteUrlString;
@property (nonatomic, readonly, copy) NSDictionary *cookie;
@property (nonatomic, readonly, copy) NSString *serviceIdentifier;
/// 查询当前是否loading
@property (nonatomic, readonly, assign) BOOL isLoading;

/// 开始请求数据
- (void)loadData;
/// 取消当前的请求
- (void)cancelRequest;



@end
