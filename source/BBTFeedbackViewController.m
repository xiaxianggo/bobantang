//
//  BBTFeedbackViewController.m
//  bobantang
//
//  Created by Xia Xiang on 10/14/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "SVProgressHUD.h"

#import "UIView+BBTWaterMark.h"
#import "BBTFeedbackViewController.h"

@interface BBTFeedbackViewController ()
@property (strong, nonatomic) UITextView *bodyTextView;
@end

@implementation BBTFeedbackViewController

- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat screenWidth = appFrame.size.width;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;

    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view.backgroundColor = [UIColor whiteColor];
        view.opaque = YES;
        
        [view addSubview:[UIView BBTwaterMarkViewWithFrame:appFrame]];
        
        CGFloat margin = 12.0f;
        CGFloat upMargin = 7.0f;
        self.bodyTextView = [[UITextView alloc] initWithFrame:CGRectMake(margin, naviBarHeight + statusBarHeight + upMargin, screenWidth - 2 * margin, 144.0f)];
        self.bodyTextView.alpha = 0.64f;
        self.bodyTextView.backgroundColor = [UIColor whiteColor];
        //self.bodyTextView.placeholder = @"有什么想告诉我们的？";
        
        [view addSubview:self.bodyTextView];
        view;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendButtonTapped:)];
    [self.bodyTextView becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)sendButtonTapped:(UIButton *)sender
{
    NSLog(@"%@", self.bodyTextView.text);
    
    if ([self feedbackIsValid]) {
        NSString *body = [self.bodyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableDictionary *parameters = [[self feedbackParameters] mutableCopy];
        parameters[@"body"] = body;
        
        
        AFHTTPSessionManager *HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://202.38.194.214:3000"]];
        HTTPSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [SVProgressHUD showWithStatus:@"正在提交反馈"];
        [HTTPSessionManager POST:@"/feedback"
                      parameters:[self feedbackParameters]
                         success:^(NSURLSessionDataTask *task, id responseObject) {
//                             NSDictionary *response = (NSDictionary *)responseObject;
//                             NSNumber *code = response[@"Code"];
                             [SVProgressHUD showWithStatus:@"发送成功，感谢您的反馈！"];
                             dispatch_time_t timeDelay = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
                             dispatch_after(timeDelay, dispatch_get_main_queue(), ^ {
                                 [SVProgressHUD dismiss];
                                 [self.navigationController popViewControllerAnimated:YES];
                             });
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             NSLog(@"%@", error);
                             [SVProgressHUD showWithStatus:@":( 不好意思，发送失败"];
                             dispatch_time_t timeDelay = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
                             dispatch_after(timeDelay, dispatch_get_main_queue(), ^ {
                                 [SVProgressHUD dismiss];
                             });
                         }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"反馈内容不能为空" message:@"请输入反馈内容" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
}

- (NSDictionary *)feedbackParameters
{
    // see feedback api doc on trello
    return  @{@"apiVersion" : @0.1,
              @"platform"   : @0, //0 stand for iOS
              @"body"       : @"",
              @"version"    : @233,
              @"contacts"   : @""
              };
}

- (BOOL)feedbackIsValid
{
    NSString *body = [self.bodyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (body.length > 0) {
        return YES;
    } else {
        return  NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
