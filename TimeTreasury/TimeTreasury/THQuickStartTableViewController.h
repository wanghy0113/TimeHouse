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
@interface THQuickStartTableViewController : UITableViewController



@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) THCoreDataManager* dataManager;
@property (strong, nonatomic) NSArray* eventModels;
@property (strong, nonatomic) THFileManager* fileManager;


@end
