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

@property (strong,nonatomic)UIImageView* duration;
@property (strong,nonatomic)UIImageView* times;
@property (strong,nonatomic)UIImageView* type;
@property (strong,nonatomic)UILabel* durationLabel;
@property (strong,nonatomic)UILabel* timesLabel;
@property (strong,nonatomic)UILabel* typeLabel;
@property (strong, nonatomic)UIView* menuView;
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
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuView:)];
        [self.contentView addGestureRecognizer:tap];
    }
    return self;
}

-(void)showMenuView:(id)sender
{
    if (!_menuView) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(EventModelCellViewWid, 0, 0, EventModelCellViewHeight)];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.layer.masksToBounds = YES;
        UIButton* detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, EventModelCellViewWid/2, EventModelCellViewHeight/4)];
        [detailButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setTitle:@"Detail" forState:UIControlStateNormal];
        [detailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        detailButton.titleLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];

        
        UIButton* editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, EventModelCellViewHeight/4, EventModelCellViewWid/2, EventModelCellViewHeight/4)];
        [editButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        editButton.titleLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
        
        UIButton* resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, EventModelCellViewHeight/2, EventModelCellViewWid/2, EventModelCellViewHeight/4)];
        [resetButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        resetButton.titleLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
        
        
        UIButton* deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, EventModelCellViewHeight*3/4, EventModelCellViewWid/2, EventModelCellViewHeight/4)];
        [deleteButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
        [_menuView addSubview:detailButton];
        [_menuView addSubview:editButton];
        [_menuView addSubview:resetButton];
        [_menuView addSubview:deleteButton];
        
        [self.contentView addSubview:_menuView];
    }
    
    if (_menuView.frame.size.width<1) {
        [UIView animateWithDuration:0.2 animations:^(void)
        {
            [_menuView setFrame:CGRectMake(EventModelCellViewWid/2, 0, EventModelCellViewWid/2, EventModelCellViewHeight)];
        }];
    }
    else
    {
//        CGPoint point = [tap locationInView:self.contentView];
//        if (point.x<EventModelCellViewWid/2) {
            [UIView animateWithDuration:0.2 animations:^(void)
             {
                 [_menuView setFrame:CGRectMake(EventModelCellViewWid, 0, 0, EventModelCellViewHeight)];
             }];
//        }
        
    }
}

-(void)menuButtonTouched:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* buttonTitle = button.titleLabel.text;
    if ([buttonTitle isEqualToString:@"Detail"]) {
        [self.delegate eventModelCell:self rowSelected:0];
    }
    else if([buttonTitle isEqualToString:@"Edit"])
    {
        [self.delegate eventModelCell:self rowSelected:1];
    }
    else if([buttonTitle isEqualToString:@"Reset"])
    {
        [self.delegate eventModelCell:self rowSelected:2];
    }
    else if([buttonTitle isEqualToString:@"Delete"])
    {
        [self.delegate eventModelCell:self rowSelected:3];
    }
    
    
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
