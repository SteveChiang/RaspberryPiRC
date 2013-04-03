//
//  ViewController.h
//  SimpleRest
//
//  Created by Steve Chiang on 12/12/18.
//  Copyright (c) 2012年 Steve Chiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceProcessor.h"
@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *mLblLightStat;
@property (nonatomic, retain) IBOutlet UISwitch *mLightSwitch;
-(IBAction)lightSwitchValueChanged:(id)sender;
-(void)reloadLightStatus;
@end
