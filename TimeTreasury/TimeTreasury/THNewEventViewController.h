//
//  THNewEventViewController.h
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

/********************************************
 about tag: rectangle frames start from 101
 labels start from 201
 button start from 301
 week day selectuon lavel start from 204
 month day seletion label start from 401
 time pick view 501 type pick view 502 weekday pick view 503
 *********************************************/

#import <UIKit/UIKit.h>
#import "THDatePickView.h"
#import "THCategoryPickerView.h"

#import "THCoreDataManager.h"
#import "EventModel.h"
#import "THFileManager.h"
#import "THJSONMan.h"
#import "ImageCropView.h"
#import "THSettingFacade.h"

#define firstMenuY  276.0
#define secondMenuY 338.0
#define thirdMenuY 375.0
#define TemporaryAudioName @"TempAudio"
#define DefaultImageName @"Default.jpeg"
@import AVFoundation;

@interface THNewEventViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate, THDatePickViewDelegate, THCategoryPickerViewDelegate>
@property (strong,nonatomic) UIImageView* photoPreView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarButtonCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarButtonDone;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIImageView *saveAsTemplateFrame;
@property (strong, nonatomic) IBOutlet UIImageView *immediateEventFrame;
@property (strong, nonatomic) IBOutlet UIImageView *plannedEventFrame;
@property (strong, nonatomic) IBOutlet UIImageView *regularEventFrame;

//for date picker view
@property (strong, nonatomic) THDatePickView *datePickerView;
//category picker view
@property (strong, nonatomic) THCategoryPickerView* categoryPickerView;

//for addTimeView
@property (strong, nonatomic) IBOutlet UIView *addTimeView;
@property (strong, nonatomic) IBOutlet UILabel *plannedStartTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *plannedEndTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *addStartTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *addEndTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *addAudioButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteAudioButton;
@property (strong, nonatomic) IBOutlet UILabel *audioLengthLabel;
@property (strong, nonatomic) IBOutlet UIButton *addCatogeryButton;
@property (strong, nonatomic) IBOutlet UILabel *addCatogeryLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *playingIndicator;

//for regular event selection
@property (strong, nonatomic) IBOutlet UIView *regularMenuView;
@property (strong, nonatomic) IBOutlet UIImageView *dailyFrame;
@property (strong, nonatomic) IBOutlet UIImageView *weeklyFrame;
@property (strong, nonatomic) IBOutlet UIImageView *monthlyFrame;
@property (strong, nonatomic) IBOutlet UIView *weekdayPickView;
@property (strong, nonatomic) IBOutlet UIView *monthdayPickView;
@property (strong, nonatomic) IBOutlet UILabel *mondayLabel;
@property (strong, nonatomic) IBOutlet UILabel *tuesdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *wednsdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *thursdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *fridayLabel;
@property (strong, nonatomic) IBOutlet UILabel *saturdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *sundayLabel;

@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;
@property (strong, nonatomic) UIImage* photo;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (assign) NSInteger datePickingRow;
@property (strong, nonatomic) NSMutableArray* weekdayArray;
@property (strong, nonatomic) NSMutableArray* monthdayArray;
@property (assign, nonatomic) BOOL isSavedAsTemplate;
@property (assign, nonatomic) THEVENTTYPE newEventType;
@property (strong, nonatomic) AVAudioRecorder* recorder;
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) NSString* photoGuid;
@property (strong, nonatomic) NSString* audioGuid;
@property (weak, nonatomic) NSTimer* audioTimer;
@property (assign) BOOL hasAudio;
@property (assign)NSInteger category;




@end
