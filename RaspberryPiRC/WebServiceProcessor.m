//
//  WebServiceProcessor.m
//  car
//
//  Created by Steve Chiang on 2011/6/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WebServiceProcessor.h"
#import "Config.h"
#import "SBJSON.h"
@interface WebServiceProcessor ()
-(void)doInit;
-(NSDictionary*)sendHttpRequest:(NSMutableURLRequest*)request error:(NSError**)error;
-(NSData*)getPostDataWithStr:(NSString*)str;
-(NSMutableURLRequest*)generateURLRequestWithUrlStr:(NSString*)urlStr
                                          andMethod:(NSString*)method
                                   forPostDataOrNil:(NSData*)postDataOrNil;
@end

@implementation WebServiceProcessor
static WebServiceProcessor *instance = nil;
+(WebServiceProcessor*)getInstance {
    @synchronized(self) {
        if (instance == nil){
            instance = [[WebServiceProcessor alloc] init];
            [instance doInit];
		}
    }
    return instance;
}

-(void)doInit {
}

-(void)dealloc {
    [instance release]; instance = nil;
    [super dealloc];
}

#pragma mark - private functions
-(NSDictionary*)sendHttpRequest:(NSMutableURLRequest*)request error:(NSError**)error {
    NSURLResponse *response = nil;
	NSData *responseData  = nil;
    NSDictionary *responseDict = nil;
    NSString *responseJSONStr = nil;
    NSInteger serverResponseStatusCode = 0;
    SBJSON *jsonParser = nil;
    
    // header
    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    serverResponseStatusCode = [response statusCode];
    if (serverResponseStatusCode != 200) {
        *error = [NSError errorWithDomain:@"WebService" code:serverResponseStatusCode userInfo:nil];
        goto EXIT;
    }
    
    if (!responseData) {
        MyLog(@"[ERROR] response: %@, error: %@", response, *error);
        goto EXIT;
    }
    
    jsonParser = [[SBJSON alloc] init];
    responseJSONStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    responseDict = [jsonParser objectWithString:responseJSONStr error:nil];
    [responseJSONStr release];
    [jsonParser release];

EXIT:
    return responseDict;
}

-(NSData*)getPostDataWithStr:(NSString*)str {
    NSData *result = nil;
    if (str) {
        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        result = [str dataUsingEncoding:NSUTF8StringEncoding];
    }

    return result;
}

-(NSMutableURLRequest*)generateURLRequestWithUrlStr:(NSString*)urlStr
                                          andMethod:(NSString*)method
                                   forPostDataOrNil:(NSData*)postDataOrNil {
    NSMutableURLRequest *request = nil;
    if (!urlStr || !method) {
        MyLog(@"[ERROR] urlStr or method is nil");
        goto EXIT;
    }
    
    if ([method isEqualToString:@"POST"] && postDataOrNil == nil) {
        MyLog(@"[ERROR] POST data is nil");
        goto EXIT;
    }
    
    request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:5];
    if ([method isEqualToString:@"POST"]) {
        [request setHTTPBody:postDataOrNil];
    }
    
EXIT:
    return request;
}

#pragma mark - public
-(BOOL)setGPIO:(NSInteger)gpio withFunction:(GPIOFunc)func {
    BOOL result = NO;
    NSDictionary *restResponse = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = nil;
    NSString *funcStr = nil;
    switch (func) {
        case GPIOFuncIn:
            funcStr = @"in";
            break;
        case GPIOFuncOut:
            funcStr = @"out";
            break;
        case GPIOFuncPWM:
            funcStr = @"pwm";
        default:
            break;
    }
    
    if (!funcStr) {
        MyLog(@"[ERROR] GPIO func set failure");
        goto EXIT;
    }
    
    request = [self generateURLRequestWithUrlStr:[NSString stringWithFormat:@"%@GPIO/%d/function/%@", HOST, gpio, funcStr]
                                       andMethod:@"POST"
                                forPostDataOrNil:[self getPostDataWithStr:@""]];
    if (!request) {
        MyLog(@"[ERROR] Generate URL request failure");
        goto EXIT;
    }
    
    restResponse = [self sendHttpRequest:request error:&error];
    if (error) {
        MyLog(@"[ERROR][%@] errCode:%d", error.domain, error.code);
        goto EXIT;
    }
    
    result = YES;
EXIT:
    return result;
}

-(BOOL)setGPIO:(NSInteger)gpio withStatus:(BOOL)on {
    BOOL result = NO;
    NSDictionary *restResponse = nil;
    NSMutableURLRequest *request = nil;
    NSError *error = nil;
    request = [self generateURLRequestWithUrlStr:[NSString stringWithFormat:@"%@GPIO/%d/value/%d", HOST, gpio, on?1:0]
                                       andMethod:@"POST"
                                forPostDataOrNil:[self getPostDataWithStr:@""]];
    if (!request) {
        MyLog(@"[ERROR] Generate URL request failure");
        goto EXIT;
    }
    
    restResponse = [self sendHttpRequest:request error:&error];
    if (error) {
        MyLog(@"[ERROR][%@] errCode:%d", error.domain, error.code);
        goto EXIT;
    }
    
    result = YES;
EXIT:
    return result;
}

-(NSDictionary*)getGPIOStatusWithPin:(NSInteger)pin {
    NSDictionary *status = nil;
    NSMutableURLRequest *request = nil;
    NSDictionary *result = nil;
    NSError *error = nil;
    request = [self generateURLRequestWithUrlStr:[NSString stringWithFormat:@"%@*", HOST]
                                       andMethod:@"GET"
                                forPostDataOrNil:nil];
    if (!request) {
        MyLog(@"[ERROR] Generate URL request failure");
        goto EXIT;
    }
    
    status = [self sendHttpRequest:request error:&error];
    if (error) {
        MyLog(@"[ERROR][%@] errCode:%d", error.domain, error.code);
        goto EXIT;
    }
    
    result = [[status objectForKey:@"GPIO"] objectForKey:[NSString stringWithFormat:@"%d", pin]];
EXIT:
    return result;
}
@end
