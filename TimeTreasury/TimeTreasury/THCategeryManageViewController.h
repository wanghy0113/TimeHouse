//
//  THCategeryManageViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCategoryProcessor.h"

@interface THCategeryManageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
