//
//  WebServiceProcessor.h
//  car
//
//  Created by Steve Chiang on 2011/6/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
typedef enum {
    GPIOFuncIn = 1,
    GPIOFuncOut,
    GPIOFuncPWM
} GPIOFunc;

@class SBJsonParser;
@interface WebServiceProcessor : NSObject
+(WebServiceProcessor*)getInstance;
-(BOOL)setGPIO:(NSInteger)gpio withFunction:(GPIOFunc)func;
-(BOOL)setGPIO:(NSInteger)gpio withStatus:(BOOL)on;
-(NSDictionary*)getGPIOStatusWithPin:(NSInteger)pin;
@end