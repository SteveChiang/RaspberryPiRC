//
//  Config.h
//  dingonet
//
//  Created by Steve on 12/4/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#define MyLog(x, ...) NSLog(@"%s " x, __FUNCTION__, ##__VA_ARGS__)
#else
#define MyLog(x, ...)
#endif

#define HOST @"http://10.0.1.202:8000/"
#define LIGHT_PIN 7