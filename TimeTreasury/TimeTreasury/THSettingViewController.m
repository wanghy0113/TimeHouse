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
@property (strong, nonatomic)NSArray* imageArray;
@end

@implementation THSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _dataSource = @[@"Category" , @"Alert", @"Reset", @"In-App Shop", @"Help", @"About"];
    _imageArray = @[@"SettingCategory", @"SettingAlert", @"SettingReset", @"SettingInappShop", @"SettingHelp", @"SettingAbout"];
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
    cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
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
        case 2:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset warning! " message:@"Do you really want to erase all data?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
            break;
        case 3:
        {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"All free for beta version, probably the same for official version :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }
            break;
        case 4:
            break;
        case 5:
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"TTAppStoryboard" bundle:nil];
            UIViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingAbout"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [NSThread detachNewThreadSelector:@selector(myThreadMainMethod:) toTarget:self withObject:nil];
    }
}

-(void)myThreadMainMethod:(id)sender
{
    BOOL res = [[THCoreDataManager sharedInstance] deleteAllData];
    if (res) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"Successfully erase all data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }
    else
    {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to erase all data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }
}

-(void)alertSwitch:(id)sender
{
    UISwitch* sw = (UISwitch*)sender;
    [THSettingFacade setAlertForEvents:sw.on];
}
@end
