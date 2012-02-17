//
//  SFUser.m
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 16/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import "SFUser.h"

@implementation SFUser

@synthesize favTitlesAr, favWavformURLAr, wavformImagesAr, favTrackIDAr, userName;

+ (SFUser *)sharedUserObj
{
    static SFUser *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFUser alloc] init];
        
        sharedInstance.favTitlesAr = [NSMutableArray arrayWithCapacity:1];
        sharedInstance.favWavformURLAr = [NSMutableArray arrayWithCapacity:1];
        sharedInstance.wavformImagesAr = [NSMutableArray arrayWithCapacity:1];
        sharedInstance.favTrackIDAr = [NSMutableArray arrayWithCapacity:1];;
    });
    
    return sharedInstance;
}

- (void)purgeUserData
{
    SFUser *sharedInstance = [SFUser sharedUserObj];
    
    sharedInstance.favTitlesAr = [NSMutableArray arrayWithCapacity:1];;
    sharedInstance.favWavformURLAr = [NSMutableArray arrayWithCapacity:1];;
    sharedInstance.wavformImagesAr = [NSMutableArray arrayWithCapacity:1];;
    sharedInstance.favTrackIDAr = [NSMutableArray arrayWithCapacity:1];;
    sharedInstance.userName = nil;
}

@end
