//
//  THEventModelCellView.h
//  TimeTreasury
//
//  Created by WangHenry on 9/4/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModel.h"


/*
 icon image view parameters
 */
#define EventModelCellViewIconX  6.0
#define EventModelCellViewIconY  6.0
#define EventModelCellViewIconW  50.0
#define EventModelCellViewIconH  50.0
#define EventModelCellViewIconCornerRadius  0.0

/*
 UILabel for name parameters
 */
#define EventModelCellViewNameLabelX  65
#define EventModelCellViewNameLabelY  10
#define EventModelCellViewNameLabelW  75
#define EventModelCellViewNameLabelH  20
#define EventModelCellViewNameFontSize 12



/*
 UILabel for category parameters
 */
#define EventModelCellViewCategoryLabelX  65
#define EventModelCellViewCategoryLabelY  35
#define EventModelCellViewCategoryLabelW  75
#define EventModelCellViewCategortLabelH  20
#define EventModelCellViewCategoryFontSize 12


/*
 label and image for type
 */
#define EventModelCellViewTypeImageViewX  40
#define EventModelCellViewTypeImageViewY  59
#define EventModelCellViewTypeImageViewW  34
#define EventModelCellViewTypeImageViewH  15
#define EventModelCellViewTypeTextFont  10

/*
 label for string "Type"
 */
#define EventModelCellViewTypeStringLabelX 10
#define EventModelCellViewTypeStringLabelY 59
#define EventModelCellViewTypeStringLabelW 30
#define EventModelCellViewTypeStringLabelH 15
#define EventModelCellViewTypeStringFontSize 10


/*
 label and image for time
 */
#define EventModelCellViewTimeImageViewX  113
#define EventModelCellViewTimeImageViewY  60
#define EventModelCellViewTimeImageViewW  30
#define EventModelCellViewTimeImageViewH  15
#define EventModelCellViewTimeTextFont  10

/*
 label for string "Time"
 */
#define EventModelCellViewTimeStringLabelX 83
#define EventModelCellViewTimeStringLabelY 60
#define EventModelCellViewTimeStringLabelW 30
#define EventModelCellViewTimeStringLabelH 15
#define EventModelCellViewTimeStringFontSize 10


/*
 label and image for duration
 */
#define EventModelCellViewDurationImageViewX  45
#define EventModelCellViewDurationImageViewY  78
#define EventModelCellViewDurationImageViewW  50
#define EventModelCellViewDurationImageViewH  15
#define EventModelCellViewDurationTextFont  10

/*
 label for string "Duration"
 */
#define EventModelCellViewDurationStringLabelX 10
#define EventModelCellViewDurationStringLabelY 78
#define EventModelCellViewDurationStringLabelW 35
#define EventModelCellViewDurationStringLabelH 15
#define EventModelCellViewDurationStringFontSize 10


/*
 attribute for cell view

 */

static const CGFloat EventModelCellViewWid = 150;
static const CGFloat EventModelCellViewHeight = 100;
static const CGFloat EventModelCellConerRadius = 10;

@protocol THEventModelCellDelegate <NSObject>

-(void)eventModelCell:(UICollectionViewCell*)cell rowSelected:(NSInteger)row;

@end

@interface THEventModelCellView : UICollectionViewCell<UITableViewDelegate, UITableViewDataSource>

-(void)setCellByEventModel:(EventModel*)model;
-(void)updateCell;
@property (assign) id<THEventModelCellDelegate> delegate;
@property (strong,atomic)EventModel* eventModel;
@end
