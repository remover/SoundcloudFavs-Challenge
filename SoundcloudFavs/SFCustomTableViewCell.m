//
//  SFCustomTableViewCell.m
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 16/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import "SFCustomTableViewCell.h"

@implementation SFCustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (id view in self.contentView.subviews) {
        if([view isMemberOfClass:[UIImageView class]])
            [view setBackgroundColor:[UIColor whiteColor]];
    }
    
}


@end
