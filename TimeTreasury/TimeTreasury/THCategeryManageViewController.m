//
//  THCategeryManageViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCategeryManageViewController.h"
static const CGFloat categoryCellHeight = 50;
static const CGFloat colorIndicatorWid = 10;
@interface THCategeryManageViewController ()
@property (strong, nonatomic)NSMutableArray* categories;
@property (strong, nonatomic)NSMutableArray* switchArray;
@property (strong, nonatomic)NSMutableArray* labelArray;
@property (assign)NSInteger alertingRow;
@end

@implementation THCategeryManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _categories = [[THCategoryProcessor getAllCategories] mutableCopy];
    _switchArray = [[NSMutableArray alloc] init];
    _labelArray = [[NSMutableArray alloc] init];
    for (int i=1; i<[_categories count]; i++) {
        NSNumber* iNum = [_categories objectAtIndex:i];
        UISwitch* swch = [[UISwitch alloc] initWithFrame:CGRectMake(260, categoryCellHeight/2-15, 45, 30)];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(60, categoryCellHeight/2-15, 180, 30)];
        label.text = [THCategoryProcessor categoryString:iNum.integerValue onlyActive:NO];
        [_labelArray addObject:label];
        if ([THCategoryProcessor categoryIsActive:iNum.integerValue]) {
            swch.on = YES;
            [_switchArray addObject:swch];
        }
        else
        {
            swch.on = NO;
            [_switchArray addObject:swch];
        }
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
    
}

#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categories count]-1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSInteger category =((NSNumber*) [_categories objectAtIndex:indexPath.row]).integerValue+1;
    UIColor* color = [THCategoryProcessor categoryColor:category onlyActive:NO];
    
    UIView* colorIndicator = [[UIView alloc] initWithFrame:CGRectMake(40, categoryCellHeight/2-colorIndicatorWid/2, colorIndicatorWid, colorIndicatorWid)];
    colorIndicator.backgroundColor = color;
    
    UISwitch* swch = [_switchArray objectAtIndex:indexPath.row];
    UILabel* label = [_labelArray objectAtIndex:indexPath.row];
    
    
    [cell.contentView addSubview:colorIndicator];
    [cell.contentView addSubview:swch];
    [cell.contentView addSubview:label];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return categoryCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Change category"
                                                        message:nil                                               delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"save", nil];
    alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [alertview textFieldAtIndex:0];
    textField.text = ((UILabel*)[_labelArray objectAtIndex:indexPath.row]).text;

    _alertingRow = indexPath.row;
    [alertview show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSLog(@"save");
        UILabel* label = [_labelArray objectAtIndex:_alertingRow];
        label.text = [alertView textFieldAtIndex:0].text;
    }
}

-(void)saveAction:(id)sender
{
    for (int i=1; i<[_categories count]; i++) {
        NSNumber* index = [_categories objectAtIndex:i];
        BOOL active = ((UISwitch*)[_switchArray objectAtIndex:i]).on;
        NSString* string = ((UILabel*)[_labelArray objectAtIndex:i]).text;
        [THCategoryProcessor setCategoryString:index.integerValue withString:string];
        [THCategoryProcessor setCategoryActive:index.integerValue withActive:active];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
