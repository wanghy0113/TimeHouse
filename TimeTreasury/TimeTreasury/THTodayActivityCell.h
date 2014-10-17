//
//  THTodayActivityCell.h
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventModel.h"
#import "THCoreDataManager.h"
@import AVFoundation;
@protocol THTodayActivityCellDelegate <NSObject>

-(void)cellMarkTouched:(UITableViewCell*)cell;

@end

@interface THTodayActivityCell : UITableViewCell<AVAudioPlayerDelegate>
typedef NS_ENUM(NSInteger, THCELLSTATUS){
    THCELLSTATUSDONE,
    THCELLSTATUSRUN,
    THCELLSTATUSWAIT
};

@property (strong,nonatomic) UIImageView* activityIcon;
@property (strong,nonatomic) UILabel* name;
@property (strong,nonatomic) UILabel* startTimeLabel;
@property (strong,nonatomic) UILabel* endTimeLabel;
@property (strong,nonatomic) UILabel* duration;
@property (strong,nonatomic) UIImageView* eventstatusMark;
@property (strong,nonatomic) UIImageView* evenTypeMark;
@property (strong,nonatomic) UIImageView* specialMark;
@property (assign,nonatomic) Event* cellEvent;

//delegate
@property (assign) id<THTodayActivityCellDelegate> delegate;

-(void)setCellByEvent:(Event*)event;

-(void)updateCell;
@end
