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

@end
static const float cellHei = 50;
@implementation THQuickStartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [THCoreDataManager sharedInstance];
    _eventModels = [_dataManager getQuickStartEventModel];
    NSLog(@"event models number: %lu", (unsigned long)[_eventModels count]);
   
    self.tableView.frame = CGRectMake(0, 0, 150, 500);
     NSLog(@"table view frame : %f, %f, %f, %f", self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);
    UIColor* color = [UIColor colorWithRed:0.464 green:0.883 blue:1 alpha:1];
    self.tableView.alpha = 1;

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



@end
