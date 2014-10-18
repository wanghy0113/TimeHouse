//
//  THQuickStartTableViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/18/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCoreDataManager.h"
#import "EventModel.h"
#import "THFileManager.h"
#import "THColorPanel.h"


@protocol THQuickStartControllerDelegate <NSObject>

-(void)quickStartDidSeletect:(UIView*)view eventModel:(EventModel*)eventModel;

@end
@interface THQuickStartTableViewController : UITableViewController <UIAlertViewDelegate>

-(void)updateView;

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) THCoreDataManager* dataManager;
@property (strong, nonatomic) NSMutableArray* eventModels;
@property (strong, nonatomic) THFileManager* fileManager;
@property (assign) id<THQuickStartControllerDelegate> delegate;

@end
