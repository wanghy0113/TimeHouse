//
//  THEventCellAccessoryView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/11/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventCellAccessoryView.h"



@interface THEventCellAccessoryView()

@end


@implementation THEventCellAccessoryView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        float buttonWid = 40;
        float buttonHeight = 30;
        UIEdgeInsets buttonInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        self.backgroundColor = [UIColor whiteColor];
        
        _audioButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWid, buttonHeight)];
        [_audioButton setImage:[UIImage imageNamed:@"AudioButton.png"] forState:UIControlStateNormal];
        _audioButton.imageEdgeInsets = buttonInsets;
        _audioButton.alpha = 0;
        [self addSubview:_audioButton];
        
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWid, 0, buttonWid, buttonHeight)];
        _shareButton.imageEdgeInsets = buttonInsets;
        [_shareButton setImage:[UIImage imageNamed:@"FacebookButton.png"] forState:UIControlStateNormal];
        [self addSubview:_shareButton];
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(2*buttonWid, 0, buttonWid, buttonHeight)];
        _editButton.imageEdgeInsets = buttonInsets;
        [_editButton setImage:[UIImage imageNamed:@"EditButton.png"] forState:UIControlStateNormal];
        [self addSubview:_editButton];
        
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(3*buttonWid, 0, buttonWid, buttonHeight)];
        _deleteButton.imageEdgeInsets = buttonInsets;
        [_deleteButton setImage:[UIImage imageNamed:@"DeleteButton.png"] forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(4*buttonWid, 0, buttonWid, buttonHeight)];
        _refreshButton.imageEdgeInsets = buttonInsets;
        [_refreshButton setImage:[UIImage imageNamed:@"RefreshButton.png"] forState:UIControlStateNormal];
        [self addSubview:_refreshButton];
    }
    return  self;
}

-(void)showAudioButton:(BOOL)show
{
    if (show) {
        _audioButton.alpha = 1;
    }
    else
    {
        _audioButton.alpha = 0;
    }
}

@end
