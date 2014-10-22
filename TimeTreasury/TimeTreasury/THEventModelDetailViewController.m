//
//  THEventModelDetailViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventModelDetailViewController.h"

@interface THEventModelDetailViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;;
@property (strong, nonatomic) NSMutableArray* eventsArray;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@end

@implementation THEventModelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    _eventsArray = [[_eventModel.event sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventsArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event* event = [_eventsArray objectAtIndex:indexPath.row];
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"EventInfoCell"];
    UILabel* indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 24, 21)];
    indexLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    [cell.contentView addSubview:indexLabel];
    
    UILabel* startLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, 160, 21)];
    startLabel.textColor = [UIColor whiteColor];
    startLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
    startLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    startLabel.text = [_dateFormatter stringFromDate:event.startTime];
    [cell.contentView addSubview:startLabel];
    
    UILabel* lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 8, 100, 21)];
    lengthLabel.textColor = [UIColor whiteColor];
    lengthLabel.font = [UIFont fontWithName:@"noteworthy-bold" size:15];
    lengthLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    lengthLabel.text = [THDateProcessor timeFromSecond:event.duration.floatValue withFormateDescriptor:@"hh:mm:ss"];
    [cell.contentView addSubview:lengthLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"TTAppStoryboard" bundle:nil];
    THEventDetailViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"EventDetail"];
    vc.event = [_eventsArray objectAtIndex:indexPath.row];
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        Event* event = [_eventsArray objectAtIndex:indexPath.row];
        [_eventsArray removeObject:event];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[THCoreDataManager sharedInstance] deleteEvent:event];
    }
}

- (IBAction)back:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}

@end
