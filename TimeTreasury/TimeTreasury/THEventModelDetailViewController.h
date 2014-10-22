//
//  THEventModelDetailViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventModel.h"
#import "THCoreDataManager.h"
#import "THDateProcessor.h"
#import "THEventDetailViewController.h"
#import "THCoreDataManager.h"
@interface THEventModelDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


@property (strong, atomic) EventModel* eventModel;
@end
