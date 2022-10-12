//
//  RKHTTPRequestOperation_Timeoutable.h
//  SNApp
//
//  Created by Force Close on 11/1/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "RKHTTPRequestOperation.h"

@interface RKHTTPRequestOperation_Timeoutable : RKHTTPRequestOperation

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

@end
