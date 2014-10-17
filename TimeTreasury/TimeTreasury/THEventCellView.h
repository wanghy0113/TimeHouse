//
//  THEventCellView.h
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventModel.h"
#import "LabelView.h"
#import "THCoreDataManager.h"

#define CELL_WID 320
#define CELL_HEIGHT 90
@import AVFoundation;
@protocol THEventCellViewDelegate <NSObject>

-(void)eventButtonTouched:(UIView*)cell;
-(void)deleteButtonTouched:(UIView*)cell;
-(void)editButtonTouched:(UIView*)cell;
-(void)shareButtonTouched:(UIView*)cell;
-(void)refreshButtonTouched:(UIView*)cell;

@end

@interface THEventCellView : UIView<AVAudioPlayerDelegate>
typedef NS_ENUM(NSInteger, THCELLSTATUS){
    THCELLSTATUSDONE,
    THCELLSTATUSRUN,
    THCELLSTATUSWAIT
};
@property (assign,atomic) Event* cellEvent;
@property (assign) id<THEventCellViewDelegate> delegate;
@property (strong,nonatomic) UIImageView* activityIcon;

-(void)setCellByEvent:(Event*)event;
-(void)updateCell;
-(void)audioButtonTouched:(UIButton*)button;
-(NSString*)convertEventToMessage;
@end
