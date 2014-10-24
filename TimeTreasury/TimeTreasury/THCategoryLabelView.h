//
//  THCategoryLabelView.h
//  TimeTreasury
//
//  Created by WangHenry on 10/23/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SketchProducer.h"
static const CGFloat categoryLabelHeight = 20;
@interface THCategoryLabelView : UIView
typedef NS_ENUM(NSInteger, THCategoryLabelType)
{
    THCategoryLabelTypeDelete,
    THCategoryLabelTypeAdd
};

@property (strong, nonatomic)UIView* categoryTextView;
@property (strong, nonatomic)UIView* typeView;
@property (strong, nonatomic)UILabel* textLabel;
-(id)initWithCategory:(NSInteger)category andType:(THCategoryLabelType)type;
-(void)setType:(THCategoryLabelType)type;

@end
