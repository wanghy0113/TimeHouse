//
//  THEventModelEditViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THNewEventViewController.h"
#import "Event.h"
#import "EventModel.h"

@interface THEventModelEditViewController : THNewEventViewController

@property (strong, atomic)EventModel* eventModel;

@end
