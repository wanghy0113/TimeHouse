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
    if (indexPath.row==1) {
        cell.detailTextLabel.text = @"push alerts for upcoming events";
        UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectMake(270, 15, 0, 0)];
        [sw addTarget:self action:@selector(alertSwitch:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:sw];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"TTAppStoryboard" bundle:nil];
            UIViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"CategoryManage"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)alertSwitch:(id)sender
{
    UISwitch* sw = (UISwitch*)sender;
    [THSettingFacade setAlertForEvents:sw.on];
}
@end
