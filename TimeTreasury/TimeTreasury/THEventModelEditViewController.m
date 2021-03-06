//
//  THEventModelEditViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventModelEditViewController.h"

@interface THEventModelEditViewController ()
@end

@implementation THEventModelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.nameField.text = _eventModel.name;
    self.category = _eventModel.category.integerValue;
    UIColor* color = [THSettingFacade categoryColor:self.category onlyActive:YES];
    UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
    NSAttributedString* astr = [[NSAttributedString alloc] initWithString:[THSettingFacade categoryString:self.category onlyActive:YES]
                                                               attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font}];
    self.addCatogeryLabel.attributedText = astr;
    
    if (_eventModel.shouldSaveAsModel) {
        self.isSavedAsTemplate = YES;
        self.saveAsTemplateFrame.image = [UIImage imageNamed:@"FrameWithCheck"];
    }
    
    
   
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    if (_eventModel.type.integerValue!=THCASUALEVENT&&_eventModel.type.integerValue!=THPLANNEDEVENT) {
        self.immediateEventFrame.image = [UIImage imageNamed:@"Frame"];;
        self.regularMenuView.alpha = 1;
        self.regularEventFrame.image = [UIImage imageNamed:@"FrameWithCheck"];;
        self.addTimeView.alpha = 1;
        if (_eventModel.planedStartTime) {
            self.plannedStartTimeLabel.text = [dateFormatter stringFromDate:_eventModel.planedStartTime];
            self.startDate = _eventModel.planedStartTime;
            [self.addStartTimeButton setImage:[UIImage imageNamed:deleteButtonImage] forState:UIControlStateNormal];
        }
        if (_eventModel.planedEndTime) {
            self.plannedEndTimeLabel.text = [dateFormatter stringFromDate:_eventModel.planedEndTime];
            self.endDate = _eventModel.planedEndTime;
            [self.addEndTimeButton setImage:[UIImage imageNamed:deleteButtonImage] forState:UIControlStateNormal];
        }
    }
    switch (_eventModel.type.integerValue) {
        case THCASUALEVENT:
            self.newEventType = THCASUALEVENT;
            break;
        case THPLANNEDEVENT:
            self.newEventType = THCASUALEVENT;
            break;
        case THDAILYEVENT:
        {
            self.newEventType = THDAILYEVENT;
            [self.datePickerView setDatePickMode:UIDatePickerModeTime];
        }
            break;
        case THWEEKLYEVENT:
        {
            self.newEventType = THWEEKLYEVENT;
            self.dailyFrame.image = [UIImage imageNamed:@"Frame"];
            self.weeklyFrame.image = [UIImage imageNamed:@"FrameWithCheck"];
            self.weekdayArray = _eventModel.regularDay;
            self.weekdayPickView.alpha = 1;
            for (int i=0; i<[self.weekdayArray count]; i++) {
                NSNumber* day = [self.weekdayArray objectAtIndex:i];
                UIView* view = [self.view viewWithTag:202+day.integerValue];
                view.layer.borderWidth=1;
                view.layer.borderColor=[[UIColor redColor] CGColor];
            }
            [self.datePickerView setDatePickMode:UIDatePickerModeTime];
        }
            break;
        case THMONTHLYEVENT:
        {
            self.newEventType = THMONTHLYEVENT;
            self.dailyFrame.image = [UIImage imageNamed:@"Frame"];
            self.monthlyFrame.image = [UIImage imageNamed:@"FrameWithCheck"];
            self.monthdayArray = _eventModel.regularDay;
            self.monthdayPickView.alpha = 1;
            for (int i=0; i<[self.monthdayArray count]; i++) {
                NSNumber* day = [self.monthdayArray objectAtIndex:i];
                UIView* view = [self.view viewWithTag:400+day.integerValue];
                view.layer.borderWidth=1;
                view.layer.borderColor=[[UIColor redColor] CGColor];
            }
            [self.datePickerView setDatePickMode:UIDatePickerModeTime];
        }
        default:
            break;
    }
    
    //set up image and audio
    if (_eventModel.photoGuid) {
        self.photoGuid = _eventModel.photoGuid;
        NSString* photoFile = [_eventModel.photoGuid stringByAppendingPathExtension:@"jpeg"];
        self.photo = [[THFileManager sharedInstance] loadImageWithFileName:photoFile];
        self.photoPreView.image = self.photo;
    }
    
    if (_eventModel.audioGuid) {
        self.hasAudio = YES;
        NSURL* url = [[THFileManager sharedInstance] getAudioURLWithName:_eventModel.audioGuid];
        [self.addAudioButton setImage:[UIImage imageNamed:recordPlayButtonImage] forState:UIControlStateNormal];
        
        NSURL* defaulturl = [[THFileManager sharedInstance] getAudioURLWithName:TemporaryAudioName];
        
        [[THFileManager sharedInstance] writeContentOfURL:url to:defaulturl];
        self.deleteAudioButton.alpha = 1;
        self.playingIndicator.alpha = 1;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:defaulturl error:nil];
        self.player.delegate = self;
        float audioDurationSeconds = self.player.duration;
        self.audioLengthLabel.text = [NSString stringWithFormat:@"%d", (int)audioDurationSeconds];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}
- (IBAction)saveAction:(id)sender {
    
    if (self.photo) {
        NSString* photoguid = @"";
        if (self.photoGuid) {
            photoguid = self.photoGuid;
        }
        else
        {
            photoguid = [[NSUUID UUID] UUIDString];
            self.photoGuid = photoguid;
        }
        [[THFileManager sharedInstance] saveImage:self.photo withFileName:[photoguid stringByAppendingPathExtension:@"jpeg"]];
    }
    
    if (self.hasAudio) {
        NSString* audioguid = @"";
        if (self.audioGuid) {
            audioguid = self.photoGuid;
            NSURL* url = [[THFileManager sharedInstance] getPhotoURLWithName:audioguid];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        else
        {
            audioguid = [[NSUUID UUID] UUIDString];
            self.audioGuid = audioguid;
        }
        
        [[THFileManager sharedInstance] renameFile:TemporaryAudioName withNewName:self.audioGuid];
    }
    
    _eventModel.name = self.nameField.text;
    _eventModel.type = [NSNumber numberWithInteger: self.newEventType];
    _eventModel.planedStartTime = self.startDate;
    _eventModel.planedEndTime = self.endDate;
    _eventModel.photoGuid = self.photoGuid;
    _eventModel.audioGuid = self.audioGuid;
    _eventModel.category = [NSNumber numberWithInteger: self.category];
    _eventModel.shouldSaveAsModel = [NSNumber numberWithBool: self.isSavedAsTemplate];
    switch (self.newEventType) {
        case THCASUALEVENT:
            _eventModel.regularDay = nil;
            break;
        case THDAILYEVENT:
            _eventModel.regularDay = nil;
            break;
        case THWEEKLYEVENT:
            _eventModel.regularDay = self.weekdayArray;
            break;
        case THMONTHLYEVENT:
            _eventModel.regularDay = self.monthdayArray;
            break;
        default:
            break;
    }
    
    [[[THCoreDataManager sharedInstance] managedObjectContext] save:nil];
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}


@end
