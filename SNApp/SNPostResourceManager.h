//
//  SNPostResourceManager.h
//  SNApp
//
//  Created by Force Close on 6/19/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ResponseServer.h"
#import "Post.h"

@interface SNPostResourceManager : NSObject

+(instancetype)sharedManager;

-(void)getPostsWithLocation:(CLLocation *)location radio:(NSNumber*)radio date:(NSDate*)date username:(NSString*)username getOlders:(BOOL)getolders success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
-(void)cancelGetPosts;
-(void)getPostsWithLocation:(CLLocation *)location radio:(NSNumber*)radio date:(NSDate*)date username:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure maxNumberOfRepetitions:(NSNumber*)repetitions;

-(void)uploadPostWithURL:(NSURL *)url withAccountId:(NSNumber*)accountID content:(NSString*)content latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude success:(void(^)(Post* post))success failure:(void(^)(NSError* error))failure;
-(void)cancelUploadPost;

-(void)wowPostWithIDAccount:(NSNumber*)aIdAccount idPost:(NSNumber*)aPostId date:(NSDate*)aDate success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelWow;

-(void)reportPostWithIdAccount:(NSNumber*)idAccount idPost:(NSNumber*)postId idAccountReport:(NSNumber*)idAccounReport detail:(NSString*)detail success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelReportPost;

@end
