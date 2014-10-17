//
//  THEventDetailViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 6/8/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventModel.h"
#import "THCoreDataManager.h"
@import AVFoundation;

@interface THEventDetailViewController : UIViewController <AVAudioPlayerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>



@property (strong, nonatomic) Event* event;




@end
