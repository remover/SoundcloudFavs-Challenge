//
//  SFUser.h
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 16/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFUser : NSObject

@property (nonatomic, strong) NSMutableArray *favTitlesAr, *favWavformURLAr, *favTrackIDAr;

@end