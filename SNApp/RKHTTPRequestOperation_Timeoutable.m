//
//  RKHTTPRequestOperation_Timeoutable.m
//  SNApp
//
//  Created by Force Close on 11/1/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "RKHTTPRequestOperation_Timeoutable.h"

@implementation RKHTTPRequestOperation_Timeoutable

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    
    NSMutableURLRequest *requestWithTimeout = [request mutableCopy];
    [requestWithTimeout setTimeoutInterval:25];
    
    return [super connection:connection willSendRequest:requestWithTimeout redirectResponse:response];
}

@end

