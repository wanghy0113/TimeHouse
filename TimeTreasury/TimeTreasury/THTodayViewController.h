//
//  THTodayViewController.h
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "THNewEventViewController.h"
#import "THCoreDataManager.h"
#import "THTodayActivityCell.h"
#import "THEventDetailViewController.h"
#import "PMCalendar.h"
@interface THTodayViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate, THTodayActivityCellDelegate, PMCalendarControllerDelegate>


-(void)updateView;

@end
