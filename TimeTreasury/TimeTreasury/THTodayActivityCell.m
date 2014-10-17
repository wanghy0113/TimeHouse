//
//  THTodayActivityCell.m
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THTodayActivityCell.h"
#import "StyleKitName.h"
#import "THDateProcessor.h"
#import "THCoreDataManager.h"
#import "THFileManager.h"
#import "THNewEventViewController.h"
static CGFloat markX = 200;
static CGFloat markY = 5;
@interface THTodayActivityCell()
@property (weak, nonatomic) NSTimer* timer;
@property (strong,nonatomic)AVAudioPlayer* player;
@property (strong,nonatomic)THCoreDataManager* dataManager;
@end



@implementation THTodayActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dataManager = [THCoreDataManager sharedInstance];
        
        //split line
        UIImageView* lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, self.bounds.size.width-10, 2)];
        lineView.image = [UIImage imageNamed:@"road1.png"];
        lineView.alpha = 0.2;
        [self.contentView addSubview:lineView];
        
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
        _activityIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        _activityIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_activityIcon];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 0, 20)];
        _name.font = [UIFont fontWithName:@"Noteworthy-Bold" size:16];
        [_name sizeToFit];
        [self.contentView addSubview:_name];
        
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 0, 25)];
        _startTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        _startTimeLabel.tintColor = [UIColor grayColor];
        _startTimeLabel.alpha = 0.5;
        [_startTimeLabel sizeToFit];
        [self.contentView addSubview:_startTimeLabel];
        
        _endTimeLabel= [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 0, 25)];
        _endTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        _endTimeLabel.tintColor = [UIColor grayColor];
        _endTimeLabel.alpha = 0.5;
        [_endTimeLabel sizeToFit];
        [self.contentView addSubview:_endTimeLabel];
        
        _duration = [[UILabel alloc] initWithFrame:CGRectMake(230, 25, 0, 30)];
        _duration.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [_duration sizeToFit];
        [self.contentView addSubview:_duration];
        
        _eventstatusMark = [[UIImageView alloc] initWithFrame:CGRectMake(markX, markY, 20, 20)];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(markPressed:)];
        [_eventstatusMark addGestureRecognizer:tap];
        [self.contentView addSubview:_eventstatusMark];
        
        _evenTypeMark = [[UIImageView alloc] initWithFrame:CGRectMake(markX-25, markY, 20, 20)];
        [self.contentView addSubview:_evenTypeMark];
        
        //special tap. used for other contents such as audio playing
        UITapGestureRecognizer* specialTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(specialMarkPressed:)];
        _specialMark = [[UIImageView alloc] initWithFrame:CGRectMake(markX+25, markY, 20, 20)];
        [_specialMark addGestureRecognizer:specialTap];
        _specialMark.userInteractionEnabled = YES;
        [self.contentView addSubview:_specialMark];
    }
    return self;
}

-(void)setCellByEvent:(Event*)event
{
  //  NSLog(@"cell is going to update");
    _cellEvent = event;
    [self updateCell];
    
}

-(void)updateCell
{
    
    Event* event = _cellEvent;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    //if cell event status is current
    if (event.status.integerValue==CURRENT) {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        //display start time
        NSString* startTime = [dateFormatter stringFromDate:event.startTime];
        self.duration.text = [THDateProcessor timeFromSecond:[[NSDate date] timeIntervalSinceDate:event.startTime] withFormateDescriptor:@"hh:mm:ss"];
        [self.duration sizeToFit];
        if (startTime) {
            self.startTimeLabel.text = [@"Start: " stringByAppendingString:startTime];
        }
        self.endTimeLabel.text = @"";
        [self.startTimeLabel sizeToFit];
        _eventstatusMark.image = [UIImage imageNamed:@"Stop.png"];
        _eventstatusMark.userInteractionEnabled = YES;
    }
    
     //if cell event status is finished
    if (event.status.integerValue==FINISHED) {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSString* startTime = [dateFormatter stringFromDate:event.startTime];
        NSString* endTime = [dateFormatter stringFromDate:event.endTime];
        self.startTimeLabel.text = [NSString stringWithFormat:@"Start: %@",startTime];
        self.endTimeLabel.text = [NSString stringWithFormat:@"to: %@",endTime];
        [self.startTimeLabel sizeToFit];
        [self.endTimeLabel sizeToFit];
        self.duration.text = [THDateProcessor timeFromSecond:event.duration.floatValue withFormateDescriptor:@"hh:mm:ss"];
        [self.duration sizeToFit];
        _eventstatusMark.image = [UIImage imageNamed:@"Done.gif"];
        _eventstatusMark.userInteractionEnabled = NO;
    }
    
     //if cell event status is unfinished
    if (event.status.integerValue==UNFINISHED) {
        if (event.eventModel.type.integerValue==THPLANNEDEVENT) {
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        }
        else
        {
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        }
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString* startTime = event.eventModel.planedStartTime==nil?@"":[dateFormatter stringFromDate:event.eventModel.planedStartTime];
        NSString* endTime =  event.eventModel.planedEndTime==nil?@"":[dateFormatter stringFromDate:event.eventModel.planedEndTime];
        self.startTimeLabel.text = [NSString stringWithFormat:@"Plan from %@ - %@",startTime,endTime];
        self.duration.text = @"Wait";
        [self.duration sizeToFit];
        [self.startTimeLabel sizeToFit];
        [self.duration sizeToFit];
        _eventstatusMark.image = [UIImage imageNamed:@"Start.png"];
        _eventstatusMark.userInteractionEnabled = YES;
        
    }
    
    if (event.eventModel.type.integerValue == THCASUALEVENT) {
        _evenTypeMark.image = [UIImage imageNamed:@"Casual.png"];
    }
    if (event.eventModel.type.integerValue == THPLANNEDEVENT) {
        _evenTypeMark.image = [UIImage imageNamed:@"Planned.png"];
    }
    if (event.eventModel.type.integerValue == THDAILYEVENT) {
        _evenTypeMark.image = [UIImage imageNamed:@"Daily.png"];
    }
    if (event.eventModel.type.integerValue == THWEEKLYEVENT) {
        _evenTypeMark.image = [UIImage imageNamed:@"Weekly.png"];
    }
    if (event.eventModel.type.integerValue == THMONTHLYEVENT) {
        _evenTypeMark.image = [UIImage imageNamed:@"Monthly.png"];
    }
    NSString* imageFileName = event.eventModel.photoGuid;
   // NSLog(@"photo guid loaded:%@",imageFileName);
    if (imageFileName) {
        imageFileName = [imageFileName stringByAppendingPathExtension:@"jpeg"];
        _activityIcon.image = [[THFileManager sharedInstance] loadImageWithFileName:imageFileName];
    }
    else
    {
        _activityIcon.image = [UIImage imageNamed:DefaultImageName];
    }
    
    if (event.eventModel.audioGuid) {
        _specialMark.image = [UIImage imageNamed:@"Audio.png"];
    }
    _activityIcon.layer.masksToBounds = YES;
    _activityIcon.layer.cornerRadius  = 3;
    self.name.text = event.eventModel.name;
    [self.name sizeToFit];

}

-(void)markPressed:(UIGestureRecognizer*)gestureRecognizer
{
    [self.delegate cellMarkTouched:self];
}

-(void)specialMarkPressed:(UIGestureRecognizer*)gestureRecognizer
{
    if (_player.playing) {
        [_player stop];
        _specialMark.image = [UIImage imageNamed:@"Audio.png"];
    }
    else {
        NSURL* url = [[THFileManager sharedInstance] getAudioURLWithName:_cellEvent.eventModel.audioGuid];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        NSLog(@"should have played");
        _specialMark.image = [UIImage imageNamed:@"AudioStop.png"];
        [_player play];
    }
}

#pragma mark - AVplayer delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _specialMark.image = [UIImage imageNamed:@"Audio.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
