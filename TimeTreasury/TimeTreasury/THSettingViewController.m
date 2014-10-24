//
//  THSettingViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THSettingViewController.h"

@interface THSettingViewController ()
@property (strong ,nonatomic)NSArray* dataSource;
@end

@implementation THSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _dataSource = @[@"Category" , @"Alert", @"Reset", @"In-App Shop", @"Help", @"About"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}


@end
