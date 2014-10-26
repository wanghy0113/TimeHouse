//
//  THEventCellAccessoryView.h
//  TimeTreasury
//
//  Created by WangHenry on 9/11/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEventCellView.h"
@interface THEventCellAccessoryView : UIView

-(void)showAudioButton:(BOOL)show;
@property (strong, nonatomic) UIButton* audioButton;
@property (strong, nonatomic) UIButton* shareButton;
@property (strong, nonatomic) UIButton* editButton;
@property (strong, nonatomic) UIButton* deleteButton;
@property (strong, nonatomic) UIButton* refreshButton;

@end
