//
//  THRegularEventViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 6/18/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEventDetailViewController.h"
#import "EventModel.h"
#import "Event.h"
#import "THCoreDataManager.h"
@interface THRegularEventViewController : UIViewController

@property (strong, nonatomic)EventModel* model;

@end
