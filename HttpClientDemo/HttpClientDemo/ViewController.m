//
//  ViewController.m
//  HttpClientDemo
//
//  Created by qq on 16/4/15.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "ViewController.h"
#import "ItemListAPICmd.h"

@interface ViewController ()<APICmdApiCallBackDelegate,APICmdParamSourceDelegate,APICmdParamSourceDelegate,APICmdAspect>
{
    UITextField *_cityPinyin;
    UITextView  *_responseResult;
}
@property (nonatomic,strong) ItemListAPICmd *itemListAPICmd;
@end

@implementation ViewController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CreateUI
-(void)createUI
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 50)];
    titleLabel.text=@"城市天气预报";
    
    _cityPinyin = [[UITextField alloc]initWithFrame:CGRectMake(100, 150, 200, 50)];
    _cityPinyin.placeholder = @"请输入查询城市的拼音";
    
    UIButton *ClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ClickButton.frame = CGRectMake(100, 200, 200, 50);
    [ClickButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [ClickButton setTitle:@"开始请求" forState:UIControlStateNormal];
    [ClickButton addTarget:self action:@selector(beginRequestAction) forControlEvents:UIControlEventTouchUpInside];
    
    _responseResult = [[UITextView alloc]initWithFrame:CGRectMake(100, 300, 200, 300)];
//    [_responseResult sizeToFit];
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:_cityPinyin];
    [self.view addSubview:ClickButton];
    [self.view addSubview:_responseResult];
}

#pragma mark - APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(BaseAPICmd *)baseAPICmd response:(URLResponse *)response
{
    _responseResult.text = response.contentString;
//    [_responseResult sizeToFit];
    NSLog(@"json=%@",response.content);
}
- (void)apiCmdDidFailed:(BaseAPICmd *)baseAPICmd errorType:(BaseAPICmdErrorType)errorType
{
    
}
#pragma mark APICmdParamSourceDelegate
- (NSDictionary *)paramsForApi:(BaseAPICmd *)apiCmd
{
    if (self.itemListAPICmd == apiCmd) {
        return @{@"city":_cityPinyin.text};
    }
    return nil;
}
#pragma mark APICmdAspect
- (void)apiCmd:(BaseAPICmd *)apiCmd request:(NSMutableURLRequest *)request
{
    
}

#pragma mark - event responses
- (void)beginRequestAction
{
    if (_cityPinyin.text.length != 0) {
        //开始请求数据
        [self.itemListAPICmd loadData];
    }
}

#pragma mark - getters

- (ItemListAPICmd *)itemListAPICmd
{
    if (!_itemListAPICmd) {
        _itemListAPICmd = [[ItemListAPICmd alloc] init];
        _itemListAPICmd.delegate    = self;
        _itemListAPICmd.paramSource = self;
        _itemListAPICmd.aspect      = self;
    }
    return _itemListAPICmd;
}



@end
