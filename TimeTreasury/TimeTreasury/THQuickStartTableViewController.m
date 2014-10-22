//
//  THQuickStartTableViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/18/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THQuickStartTableViewController.h"
#import "THNewEventViewController.h"
@interface THQuickStartTableViewController ()
@property (strong, nonatomic)UITableViewCell* alertingView;
@end
static const float cellHei = 50;
@implementation THQuickStartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [THCoreDataManager sharedInstance];
    _eventModels = [[_dataManager getQuickStartEventModel] mutableCopy];
  //  UIColor* color = [UIColor colorWithRed:0.808 green:0.819 blue:0.852 alpha:0.95];
    
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    title.textAlignment = NSTextAlignmentCenter;

    title.text = @"Quick Start";
    self.tableView.tableHeaderView = title;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.alpha = 0.95;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

-(void)updateView
{
    _eventModels = [[_dataManager getQuickStartEventModel] mutableCopy];
    [self.tableView reloadData];
}


#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventModels count];
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return cellHei;
}


#pragma mark - table view data source
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"StartListCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"StartListCell"];
    }
    if (!_fileManager) {
        _fileManager = [THFileManager sharedInstance];
    }
    
    EventModel* eventModel = [_eventModels objectAtIndex:[indexPath row]];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 5, cellHei-10, cellHei-10)];
    [cell.contentView addSubview:imageView];
    if (eventModel.photoGuid) {
        NSString* imageFileName = [eventModel.photoGuid stringByAppendingPathExtension:@"jpeg"];
        imageView.image = [[THFileManager sharedInstance] loadImageWithFileName:imageFileName];
    }

    imageView.layer.cornerRadius = 3;
    imageView.layer.masksToBounds = YES;
    UIFont* fontContent = [UIFont fontWithName:@"NoteWorthy-bold" size:14];
    NSString* category = eventModel.catogery;
    NSString* name = eventModel.name;
    UIColor* color1 = [THColorPanel getColorFromCategory:category];
    UIColor* color2 = [UIColor blackColor];
    if ([category length]==0) {
        category = @"Uncategrized";
        color1 = [UIColor grayColor];
    }
    
    if ([name length]==0) {
        name = @"No name";
        color2 = [UIColor grayColor];
    }

    NSDictionary* dicColorfulContent = @{NSForegroundColorAttributeName:color1,
                                         NSFontAttributeName:fontContent};
    NSDictionary* dicContent = @{NSForegroundColorAttributeName:color2,
                                 NSFontAttributeName:fontContent};
    
    
    NSMutableAttributedString* nameStr = [[NSMutableAttributedString alloc] initWithString:name
                                                                                attributes:dicContent];

    cell.textLabel.attributedText = nameStr;
    
    NSMutableAttributedString* categoryStr = [[NSMutableAttributedString alloc] initWithString:category
                                                                                    attributes:dicColorfulContent];
    cell.detailTextLabel.attributedText = categoryStr;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _alertingView = [self.tableView cellForRowAtIndexPath:indexPath];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start"
                                                    message:@"Do you want to start?"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
    [alert show];
}
    
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EventModel* model = [_eventModels objectAtIndex:indexPath.row];
        model.shouldSaveAsModel = false;
        [_dataManager saveContext];
        [_eventModels removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"!!!!!");
    if ([alertView.title isEqualToString:@"Start"]) {
        if (buttonIndex==0) {
            NSLog(@"!!!!!");
            NSInteger index = [self.tableView indexPathForCell:_alertingView].row;
            [self.delegate quickStartDidSeletect:self.tableView eventModel:[_eventModels objectAtIndex:index]];
        }
    }
    _alertingView = nil;
}


@end
