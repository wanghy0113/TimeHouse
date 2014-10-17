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
static float CELL_WID = 155;
static float CELL_HEIGHT = 100;
@interface THEventModelCellView()

@property (strong,nonatomic)UIImageView* activityIcon;
@property (strong,nonatomic)UITextView* name;
@property (strong,atomic)EventModel* eventModel;
@property (strong,nonatomic)UIImageView* duration;
@property (strong,nonatomic)UIImageView* times;
@property (strong,nonatomic)UIImageView* type;
@property (strong,nonatomic)UILabel* durationLabel;
@property (strong,nonatomic)UILabel* timesLabel;
@property (strong,nonatomic)UILabel* typeLabel;

@end
@implementation THEventModelCellView

- (id)init
{
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, CELL_WID, CELL_HEIGHT);
        //split line
        UIImageView* lineView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 98, self.bounds.size.width-10, 2)];
        lineView.image = [UIImage imageNamed:@"road1.png"];
        lineView.alpha = 0.2;
        [self addSubview:lineView];
        
        
        _activityIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 50, 50)];
        _activityIcon.layer.cornerRadius = 16;
        _activityIcon.layer.masksToBounds = YES;
        [self addSubview:_activityIcon];
        
        _name = [[UITextView alloc] initWithFrame:CGRectMake(65, 10, 75, 50)];
        _name.font = [UIFont fontWithName:@"Noteworthy-bold" size:12];
        _name.editable = NO;
        _name.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_name];
        
        _type = [[UIImageView alloc] initWithFrame:CGRectMake(40, 59, 34, 15)];
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 59, 34, 15)];
        _typeLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:10];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        UILabel* _typeText = [[UILabel alloc] initWithFrame:CGRectMake(10, 59, 30, 15)];
        _typeText.text = @"Type: ";
        _typeText.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        
        
        
        _times = [[UIImageView alloc] initWithFrame:CGRectMake(113, 60, 30, 15)];
        _times.image = [UIImage imageNamed:@"EventModelTimes.png"];
        _timesLabel = [[UILabel alloc] initWithFrame:CGRectMake(113, 60, 30, 15)];
        _timesLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:10];
        _timesLabel.textAlignment = NSTextAlignmentCenter;
        UILabel* _timesText = [[UILabel alloc] initWithFrame:CGRectMake(83, 60, 30, 15)];
        _timesText.text = @"Done: ";
        _timesText.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        
        _duration = [[UIImageView alloc] initWithFrame:CGRectMake(45, 78, 50, 15)];
        _duration.image = [UIImage imageNamed:@"EventModelDuration.png"];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 78, 50, 15)];
        _durationLabel.font = [UIFont fontWithName:@"Noteworthy-bold" size:10];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        UILabel* _durationText = [[UILabel alloc] initWithFrame:CGRectMake(10, 78, 35, 15)];
        _durationText.text = @"Total: ";
        _durationText.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        
        
        [self addSubview:_times];
        [self addSubview:_type];
        [self addSubview:_duration];
        [self addSubview:_timesLabel];
        [self addSubview:_typeLabel];
        [self addSubview:_durationLabel];
        [self addSubview:_typeText];
        [self addSubview:_durationText];
        [self addSubview:_timesText];
    }
    return self;
}

-(void)setCellByEventModel:(EventModel*)model
{
    //  NSLog(@"cell is going to update");
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
