//
//  THEventModelCellView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/4/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventModelCellView.h"
#import "EventModel.h"
#import "THFileManager.h"
#import "THNewEventViewController.h"
#import "Event.h"
#import "THCoreDataManager.h"
#import "THDateProcessor.h"

@interface THEventModelCellView()

@property (strong,nonatomic)UIImageView* activityIcon;
@property (strong,nonatomic)UILabel* name;
@property (strong, nonatomic)UILabel* category;
@property (strong,atomic)EventModel* eventModel;
@property (strong,nonatomic)UIImageView* duration;
@property (strong,nonatomic)UIImageView* times;
@property (strong,nonatomic)UIImageView* type;
@property (strong,nonatomic)UILabel* durationLabel;
@property (strong,nonatomic)UILabel* timesLabel;
@property (strong,nonatomic)UILabel* typeLabel;

@end
@implementation THEventModelCellView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView* pin = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, -5, 15, 20)];
        pin.image = [UIImage imageNamed:@"pushpin@2x"];
        [self.contentView addSubview:pin];
        
        
        _activityIcon = [[UIImageView alloc] initWithFrame:CGRectMake(EventModelCellViewIconX, EventModelCellViewIconY, EventModelCellViewIconW, EventModelCellViewIconH)];
        _activityIcon.layer.cornerRadius = EventModelCellViewIconCornerRadius;
        _activityIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_activityIcon];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewNameLabelX, EventModelCellViewNameLabelY, EventModelCellViewNameLabelW, EventModelCellViewNameLabelH)];
        _name.font = [UIFont fontWithName:@"Noteworthy-bold" size:EventModelCellViewNameFontSize];
        _name.backgroundColor = [UIColor clearColor];
        _name.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_name];
        
        _category = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewCategoryLabelX, EventModelCellViewCategoryLabelY, EventModelCellViewCategoryLabelW, EventModelCellViewCategortLabelH)];
        
        
        _type = [[UIImageView alloc] initWithFrame:CGRectMake(EventModelCellViewTypeImageViewX, EventModelCellViewTypeImageViewY, EventModelCellViewTypeImageViewW, EventModelCellViewTypeImageViewH)];
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewTypeImageViewX, EventModelCellViewTypeImageViewY, EventModelCellViewTypeImageViewW, EventModelCellViewTypeImageViewH)];
        _typeLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:EventModelCellViewTypeTextFont];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        
        
        UILabel* _typeText = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewTypeStringLabelX, EventModelCellViewTypeStringLabelY, EventModelCellViewTypeStringLabelW, EventModelCellViewTypeStringLabelH)];
        _typeText.text = @"Type: ";
        _typeText.font = [UIFont fontWithName:@"HelveticaNeue" size:EventModelCellViewTypeStringFontSize];
        
        
        
        _times = [[UIImageView alloc] initWithFrame:CGRectMake(EventModelCellViewTimeImageViewX, EventModelCellViewTimeImageViewY, EventModelCellViewTimeImageViewW, EventModelCellViewTimeImageViewH)];
        _times.image = [UIImage imageNamed:@"EventModelTimes.png"];
        _timesLabel = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewTimeImageViewX, EventModelCellViewTimeImageViewY, EventModelCellViewTimeImageViewW, EventModelCellViewTimeImageViewH)];
        _timesLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:EventModelCellViewTimeTextFont];
        _timesLabel.textAlignment = NSTextAlignmentCenter;
        UILabel* _timesText = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewTimeStringLabelX, EventModelCellViewTimeStringLabelY, EventModelCellViewTimeStringLabelW, EventModelCellViewTimeStringLabelH)];
        _timesText.text = @"Done: ";
        _timesText.font = [UIFont fontWithName:@"HelveticaNeue" size:EventModelCellViewTimeStringFontSize];
        
        _duration = [[UIImageView alloc] initWithFrame:CGRectMake(EventModelCellViewDurationImageViewX, EventModelCellViewDurationImageViewY, EventModelCellViewDurationImageViewW, EventModelCellViewDurationImageViewH)];
        _duration.image = [UIImage imageNamed:@"EventModelDuration.png"];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewDurationImageViewX, EventModelCellViewDurationImageViewY, EventModelCellViewDurationImageViewW, EventModelCellViewDurationImageViewH)];
        _durationLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:EventModelCellViewDurationTextFont];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        UILabel* _durationText = [[UILabel alloc] initWithFrame:CGRectMake(EventModelCellViewDurationStringLabelX, EventModelCellViewDurationStringLabelY, EventModelCellViewDurationStringLabelW, EventModelCellViewDurationStringLabelH)];
        _durationText.text = @"Total: ";
        _durationText.font = [UIFont fontWithName:@"HelveticaNeue" size:EventModelCellViewDurationStringFontSize];
        
        
        [self.contentView addSubview:_times];
        [self.contentView addSubview:_type];
        [self.contentView addSubview:_duration];
        [self.contentView addSubview:_timesLabel];
        [self.contentView addSubview:_typeLabel];
        [self.contentView addSubview:_durationLabel];
        [self.contentView addSubview:_typeText];
        [self.contentView addSubview:_durationText];
        [self.contentView addSubview:_timesText];
    }
    return self;
}




-(void)setCellByEventModel:(EventModel*)model
{
    _eventModel = model;
    [self updateCell];
}

-(void)updateCell
{
    
    EventModel* eventModel = _eventModel;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSString* imageFileName = eventModel.photoGuid;
    NSSet* events = _eventModel.event;
   // NSLog(@"Model %@ contains %ld events....",eventModel.name, [events count]);
    CGFloat seconds = 0;
    NSInteger eventCount = 0;
    for (int i=0; i<[events count]; i++) {
        
        Event* event = (Event*)[events.allObjects objectAtIndex:i];
        seconds+=event.duration.floatValue;
        if(event.status.integerValue==FINISHED)
        {
            eventCount++;
        }
    }
    
    switch (eventModel.type.integerValue) {
        case THDAILYEVENT:
            _type.image = [UIImage imageNamed:@"EventModelDaily.png"];
            _typeLabel.text = @"Daily";
            break;
        case THWEEKLYEVENT:
            _type.image = [UIImage imageNamed:@"EventModelWeekly.png"];
             _typeLabel.text = @"Weekly";
            break;
        case THMONTHLYEVENT:
            _type.image = [UIImage imageNamed:@"EventModelMonthly.png"];
             _typeLabel.text = @"Monthly";
            break;
        case THYEARLYEVENT:
            _type.image = [UIImage imageNamed:@"EventModelYearly.png"];
             _typeLabel.text = @"Yearly";
            break;
        default:
            break;
    }
    
    _durationLabel.text = [THDateProcessor timeFromSecond:seconds           withFormateDescriptor:@"dddhhhmmmsss"];
    _timesLabel.text = [NSString stringWithFormat:@"%ld",(long)eventCount];
    
    
    if (imageFileName) {
        imageFileName = [imageFileName stringByAppendingPathExtension:@"jpeg"];
        _activityIcon.image = [[THFileManager sharedInstance] loadImageWithFileName:imageFileName];
    }
    else
    {
        _activityIcon.image = [UIImage imageNamed:DefaultImageName];
    }
    
    if (eventModel.audioGuid) {
       
    }
    self.name.text = eventModel.name;
}




@end
