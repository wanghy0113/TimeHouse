//
//  THEventCellView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventCellView.h"
#import "SketchProducer.h"
#import "THFileManager.h"
#import "THNewEventViewController.h"
#import "THDateProcessor.h"
#import "THEventCellAccessoryView.h"
#import "THColorPanel.h"

static const float labelY = 5.0;
@interface THEventCellView()
{
    BOOL isShowingAccessoryView;
    float right1X;
    float right2X;
    float right3X;
    float categoryWid;
    
}
//set timer to weak so that it can be released after calling "invalidate"
@property (weak, nonatomic) NSTimer* timer;
@property (strong,nonatomic)AVAudioPlayer* player;
@property (strong,nonatomic)UIButton* eventButton;
@property (strong, nonatomic)UILabel* durationText;

@property (strong,nonatomic) UILabel* name;
@property (strong,nonatomic) UILabel* interValLabel;
@property (strong,nonatomic) UILabel* totalTimeLabel;
@property (strong,nonatomic)UIImageView* durationImageView;
@property (assign,nonatomic) THCELLSTATUS cellStatus;
@property (strong, nonatomic)LabelView* runningLabel;
@property (strong, nonatomic)THEventCellAccessoryView* menuView;
@property (strong, nonatomic)UILabel* timeLabel;
@property (strong, nonatomic)CAShapeLayer* timeLabelLayer;
@end


@implementation THEventCellView

- (id)init
{
    self = [super init];
    if (self) {
        right1X = 268;
        right2X = 268;
        right3X = right1X-dataTypeLabelWid;
       // self.bounds = CGRectMake(0, 0, CELL_WID, CELL_HEIGHT);
        self.backgroundColor = [UIColor whiteColor];
        isShowingAccessoryView = false;

        //split line
        UIImageView* lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 88, self.bounds.size.width-10, 2)];
        lineView.image = [UIImage imageNamed:@"road1.png"];
        lineView.alpha = 0.2;
        [self.contentView addSubview:lineView];
        
        _activityIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6,8, 74, 74)];
        _activityIcon.layer.cornerRadius = 8;
        _activityIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_activityIcon];
        
        
        _interValLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 55, 240, 15)];
        _interValLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:11];
        [self.contentView addSubview:_interValLabel];
        
        _totalTimeLabel= [[UILabel alloc] initWithFrame:CGRectMake(93, 70, 240, 15)];
        _totalTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-bold" size:12];
        [self.contentView addSubview:_totalTimeLabel];

        _name = [[UILabel alloc] initWithFrame:CGRectMake(93, 15, 160, 30)];
        _name.font = [UIFont fontWithName:@"Noteworthy-bold" size:16];
        [self.contentView addSubview:_name];
        
        _eventButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 56, 40, 30)];
        _eventButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [_eventButton addTarget:self action:@selector(eventButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_eventButton];
        
        _menuView = [[THEventCellAccessoryView alloc] initWithFrame:CGRectMake(80, 86, 200, 0)];
        _menuView.layer.masksToBounds = YES;
        _menuView.cellView = self;
        [self.contentView addSubview:_menuView];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        [self.contentView addGestureRecognizer:tap];
        
        //unselectable
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

-(void)setCellByEvent:(Event*)event
{
    [self setValue:event forKey:@"cellEvent"];
    [self updateCell];
    
}

-(void)updateCell
{
    Event* event = _cellEvent;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSString* category = _cellEvent.eventModel.catogery;
    
    
    
    if (![category isEqualToString:@"Uncategorized"]) {
        //get category label location and size
        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentNatural;
        NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Noteworthy-Bold" size: textSize], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};
        NSAttributedString* atrStr = [[NSAttributedString alloc] initWithString:category
                                                                     attributes:textFontAttributes];
        CGRect rect = [atrStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, labelHei)
                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                             context:nil];
        right2X = right1X-triangleWid-rect.size.width-8;
        right3X = right2X-dataTypeLabelWid;
        categoryWid = rect.size.width+triangleWid+8;
    }
    
    
    //if cell event status is current
    if (event.status.integerValue==CURRENT) {
        //add timer
       // _runningLabel = [[LabelView alloc] initWithFrame:CGRectMake(251, 23, 60, 15)];
        _timeLabelLayer = [SketchProducer getFlashLayer:CGRectMake(right3X-19, labelY, 68, labelHei) withColor:nil];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(right3X-21, labelY, 60, labelHei)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:textSize];
        _timeLabel.text = @"0:00:00";
        
        [self.contentView.layer addSublayer:_timeLabelLayer];
        [self.contentView addSubview:_timeLabel];
        [self updateDuration:nil];
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDuration:) userInfo:nil repeats:YES];
        }
        
        
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        
        //display start time
        NSString* startTime = [dateFormatter stringFromDate:event.startTime];
        if (startTime) {
            self.interValLabel.text = [@"Start: " stringByAppendingString:startTime];
        }
        self.totalTimeLabel.text = @"";
        [_eventButton setImage:[UIImage imageNamed:@"StopButton.png"] forState:UIControlStateNormal];
      //  [self addSubview:_runningLabel];
        [self setNeedsDisplay];
    }
    
    //if cell event status is finished
    if (event.status.integerValue==FINISHED) {
        //close timer
        [_timeLabel removeFromSuperview];
        [_timeLabelLayer removeFromSuperlayer];
        if(_timer)
        {
            [_timer invalidate];
        }
        
        [dateFormatter setDateFormat:@"MMM d, h:mma"];
        
        NSString* startTime = [dateFormatter stringFromDate:event.startTime];
        NSString* endTime = [dateFormatter stringFromDate:event.endTime];
        self.interValLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime, endTime];
        self.totalTimeLabel.text = [NSString stringWithFormat:@"Total: %@",[THDateProcessor timeFromSecond:event.duration.floatValue withFormateDescriptor:@"hh:mm:ss"]];
        [_eventButton setImage:[UIImage imageNamed:@"BranchButton.png"] forState:UIControlStateNormal];
        [self.interValLabel sizeToFit];
        [self.totalTimeLabel sizeToFit];
        [self setNeedsDisplay];
    }
    
    //if cell event status is unfinished
    if (event.status.integerValue==UNFINISHED) {
        //close timer
        [_timeLabel removeFromSuperview];
        [_timeLabelLayer removeFromSuperlayer];
        if(_timer)
        {
            [_timer invalidate];
        }
        
        if (event.eventModel.type.integerValue==THPLANNEDEVENT) {
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        }
        else
        {
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        }
        [_eventButton setImage:[UIImage imageNamed:@"StartButton.png"] forState:UIControlStateNormal];
        [dateFormatter setDateFormat:@"h:mma"];
        NSString* startTime = event.eventModel.planedStartTime==nil?@"":[dateFormatter stringFromDate:event.eventModel.planedStartTime];
        NSString* endTime =  event.eventModel.planedEndTime==nil?@"":[dateFormatter stringFromDate:event.eventModel.planedEndTime];
        self.interValLabel.text = [NSString stringWithFormat:@"Plan: %@ - %@",startTime,endTime];
        self.totalTimeLabel.text = @"";
        [self setNeedsDisplay];
        
    }
    NSString* imageFileName = event.eventModel.photoGuid;
    if (imageFileName) {
        imageFileName = [imageFileName stringByAppendingPathExtension:@"jpeg"];
        _activityIcon.image = [[THFileManager sharedInstance] loadImageWithFileName:imageFileName];
    }
    else
    {
        _activityIcon.image = [UIImage imageNamed:DefaultImageName];
    }
    
    if (event.eventModel.audioGuid) {
        [_menuView showAudioButton:true];
    }
    else
    {
        [_menuView showAudioButton:false];
    }
    self.name.text = event.eventModel.name;
}

-(void)eventButtonPressed:(id)sender
{
    [self.delegate eventButtonTouched:self];
}

-(void)audioButtonTouched:(UIButton *)button
{
    if (_player.playing) {
        [_player stop];
    }
    else {
        NSURL* url = [[THFileManager sharedInstance] getAudioURLWithName:_cellEvent.eventModel.audioGuid];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        [_player play];
    }
}

-(NSString*)convertEventToMessage
{
    NSString* res = nil;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    if (_cellEvent.status.integerValue==CURRENT) {
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        res = [NSString stringWithFormat:@"Now doing %@ from %@", self.name.text, [dateFormatter stringFromDate:_cellEvent.startTime]];
    }
    else if(_cellEvent.status.integerValue ==UNFINISHED)
    {
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        res = [NSString stringWithFormat:@"Will %@ today",self.name.text];
        if (_cellEvent.eventModel.planedStartTime!=nil) {
            res = [res stringByAppendingString:[NSString stringWithFormat:@" from %@",[dateFormatter stringFromDate:_cellEvent.eventModel.planedStartTime]]];
        }
        if (_cellEvent.eventModel.planedEndTime!=nil) {
            res = [res stringByAppendingString:[NSString stringWithFormat:@" to %@",[dateFormatter stringFromDate:_cellEvent.eventModel.planedEndTime]]];
        }
        res = [res stringByAppendingString:@"."];
    }
    else if(_cellEvent.status.integerValue==FINISHED)
    {
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        res = [NSString stringWithFormat:@"Spent %@ doing %@ from %@ to %@.", [THDateProcessor timeFromSecond:_cellEvent.duration.floatValue withFormateDescriptor:@"dddhhhmmmsss"], self.name.text, [dateFormatter stringFromDate:_cellEvent.startTime],[dateFormatter stringFromDate:_cellEvent.endTime]];
    }
    return res;
}

#pragma mark - AVplayer delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
   
}

#pragma timer handler
-(void)updateDuration:(id)sender
{
    if (_cellEvent) {
        NSDate* date = _cellEvent.startTime;
        
        CGFloat intervalSeconds = [[NSDate date] timeIntervalSinceDate:date];
        [_timeLabel setText:[THDateProcessor timeFromSecond:intervalSeconds withFormateDescriptor:@"hh:mm:ss"]];
    }
    
}

#pragma tap gesture handler
-(void)tapGestureHandler:(UIGestureRecognizer*)gesture
{
    if (isShowingAccessoryView) {
        [UIView animateWithDuration:0.5 animations:^void{
            [_menuView setFrame:CGRectMake(80, 86, 200, 0)];
        }];
        isShowingAccessoryView = false;
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^void{
            [_menuView setFrame:CGRectMake(80, 56, 200, 30)];
        }];
        isShowingAccessoryView = true;
    }
    
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(_cellEvent)
    {
        
        switch (_cellEvent.eventModel.type.integerValue) {
            case THCASUALEVENT:
                [SketchProducer produceOnceMark:CGPointMake(right1X, labelY)];
                break;
            case THPLANNEDEVENT:
                [SketchProducer produceOnceMark:CGPointMake(right1X, labelY)];
                break;
            case THDAILYEVENT:
                [SketchProducer produceDailyMark:CGPointMake(right1X, labelY)];
                break;
            case THWEEKLYEVENT:
                [SketchProducer produceWeeklyMark:CGPointMake(right1X, labelY)];
                break;
            case THMONTHLYEVENT:
                [SketchProducer produceMonthlyMark:CGPointMake(right1X, labelY)];
                break;
            default:
                break;
        }
        
        NSString* category = _cellEvent.eventModel.catogery;
        if ([category length]>0) {
            UIColor* color = [THColorPanel getColorFromCategory:category];
            CGFloat red;
            CGFloat green;
            CGFloat blue;
            [color getRed:&red green:&green blue:&blue alpha:nil];
            UIColor* newColor = [UIColor colorWithRed:red green:green blue:blue alpha:colorAlpha];
            [SketchProducer drawLabel:CGRectMake(right2X, labelY, categoryWid, labelHei)
                            withColor: newColor
                             withText:category];
        }
        
        switch (_cellEvent.status.integerValue) {
            case CURRENT:
                break;
            case FINISHED:
                [SketchProducer produceDoneMark:CGPointMake(right3X, labelY)];
                break;
            case UNFINISHED:
                [SketchProducer produceFutureMark:CGPointMake(right3X, labelY)];
            default:
                break;
        }
    }
}
@end
