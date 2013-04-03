//
//  ViewController.m
//  SimpleRest
//
//  Created by Steve Chiang on 12/12/18.
//  Copyright (c) 2012年 Steve Chiang. All rights reserved.
//

#import "Config.h"
#import "ViewController.h"
@interface ViewController ()
-(void)setLightOn:(BOOL)isOn;
@end

@implementation ViewController
@synthesize mLblLightStat;
@synthesize mLightSwitch;
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) dealloc {
    [mLblLightStat release];
    [mLightSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
-(IBAction)lightSwitchValueChanged:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    [self setLightOn:[sw isOn]];
}

#pragma mark - private - light
-(void)setLightOn:(BOOL)isOn {
    WebServiceProcessor *wp = [WebServiceProcessor getInstance];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        if ([wp setGPIO:LIGHT_PIN withFunction:GPIOFuncOut]) {
            [wp setGPIO:LIGHT_PIN withStatus:isOn];
        }
    } else {
        [mLblLightStat setText:@"傳送指令中"];
        dispatch_queue_t queue = dispatch_queue_create("WebServiceQueue", NULL);
        dispatch_async(queue, ^(void) {
            BOOL success = NO;            
            if ([wp setGPIO:LIGHT_PIN withFunction:GPIOFuncOut]) {
                success = [wp setGPIO:LIGHT_PIN withStatus:isOn];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (success) {
                    [mLblLightStat setText:@"指令已送達"];
                } else {
                    [mLblLightStat setText:@"指令傳送失敗"];
                }
            });
        });
        dispatch_release(queue);
    }
}

#pragma mark - public
-(void)reloadLightStatus {
    dispatch_queue_t queue = dispatch_queue_create("WebServiceQueue", NULL);
    dispatch_async(queue, ^(void) {
        WebServiceProcessor *wp = [WebServiceProcessor getInstance];
        NSDictionary *status = [wp getGPIOStatusWithPin:LIGHT_PIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSString *statusToShow = @"狀態查詢失敗";
            if (status) {
                switch ([[status objectForKey:@"value"] integerValue]) {
                    case 0:
                        statusToShow = @"初始狀態: 關";
                        [mLightSwitch setOn:NO];
                        break;
                    case 1:
                        statusToShow = @"初始狀態: 開";
                        [mLightSwitch setOn:YES];
                        break;
                }
            }
            
            [mLblLightStat setText:statusToShow];
        });
    });
    dispatch_release(queue);
}
@end
