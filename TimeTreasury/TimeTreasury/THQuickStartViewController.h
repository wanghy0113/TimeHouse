//
//  THQuickStartViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventModel.h"
#import "THCoreDataManager.h"
@protocol THQuickStartViewDelegate <NSObject>

-(void)newEventAdded:(Event*)event;

@end

@interface THQuickStartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView* tableView;
@property (assign) id<THQuickStartViewDelegate> delegate;




@end
