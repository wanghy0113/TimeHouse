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

@property (strong, nonatomic)THEventCellView* cellView;
-(void)showAudioButton:(BOOL)show;
@end
