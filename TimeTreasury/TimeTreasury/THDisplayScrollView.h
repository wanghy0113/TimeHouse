//
//  THDisplayScrollView.h
//  TimeTreasury
//
//  Created by WangHenry on 9/3/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEventCellView.h"
@interface THDisplayScrollView : UIScrollView
-(void)addEventCell:(THEventCellView*)eventCell animation:(BOOL)animation initialFrame:(CGRect)frame;
-(void)deleteEventCell:(THEventCellView*)eventCell;
@end
