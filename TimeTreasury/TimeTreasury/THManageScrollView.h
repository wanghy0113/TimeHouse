//
//  THManageScrollView.h
//  TimeTreasury
//
//  Created by WangHenry on 9/4/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEventModelCellView.h"
@interface THManageScrollView : UIScrollView
-(void)addEventModelCell:(THEventModelCellView*)cell;
@end
