//
//  THQuickStartTableViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/18/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THQuickStartTableViewController.h"

@interface THQuickStartTableViewController ()

@end

@implementation THQuickStartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [THCoreDataManager sharedInstance];
    _eventModels = [_dataManager getQuickStartEventModel];
    NSLog(@"event models number: %lu", (unsigned long)[_eventModels count]);

}

#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"event models number: %lu", (unsigned long)[_eventModels count]);
    return [_eventModels count];
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    NSString* imageFileName = [eventModel.photoGuid stringByAppendingPathExtension:@"jpeg"];
    cell.imageView.image = [[THFileManager sharedInstance] loadImageWithFileName:imageFileName];
    UIFont* font = [UIFont fontWithName:@"NoteWorthy" size:12];
    cell.textLabel.font = font;
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", eventModel.name];
    
    UIColor* color = [THColorPanel getColorFromCategory:eventModel.catogery];
    NSAttributedString* atrstr = [[NSAttributedString alloc] initWithString:eventModel.catogery
                                                                 attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
    cell.detailTextLabel.attributedText = atrstr;
    return cell;
}



@end
