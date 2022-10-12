//
//  SNCommentsResourceManager.h
//  SNApp
//
//  Created by Force Close on 6/29/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
@interface SNCommentsResourceManager : NSObject

+(instancetype)sharedManager;

-(void)getCommentsWithPostId:(NSNumber*)aPostId success:(void(^)(NSArray* data))success failure:(void(^)(NSError* error))failure;
-(void)cancelGetComments;

-(void)commentWhitContent:(NSString*)aContent username:(NSString*)aUsername idPost:(NSNumber*)aIdPost success:(void(^)(NSNumber* idComment))success failure:(void(^)(NSError* error))failure;
-(void)cancelComment;

-(void)reloadComments:(NSNumber*)aPostID date:(NSDate*)aDate success:(void(^)(NSArray* data))success failure:(void(^)(NSError* error))failure;
-(void)cancelReloadComments;

@end
