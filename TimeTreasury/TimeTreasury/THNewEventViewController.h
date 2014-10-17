//
//  THNewEventViewController.h
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDatePickView.h"
#import "THCategoryPickerView.h"
#define DefaultImageName @"Default.jpeg"
@import AVFoundation;

@interface THNewEventViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate, THDatePickViewDelegate, THCategoryPickerViewDelegate>
@property (strong,nonatomic) UIImageView* photoPreView;

@end
