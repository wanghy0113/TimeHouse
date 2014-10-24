//
//  THSettingViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
