//
//  THEventManagementViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 6/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventManagementViewController.h"
#import "THCoreDataManager.h"
#import "THFileManager.h"
#import "THRegularEventViewController.h"
#import "THManageScrollView.h"
#import "THEventModelCellView.h"
@interface THEventManagementViewController ()

@property (strong, nonatomic)THCoreDataManager* manager;

@property (strong, nonatomic)THManageScrollView* scrollView;
@property (strong, nonatomic)NSArray* dailyArray;
@property (strong, nonatomic)NSArray* weeklyArray;
@property (strong, nonatomic)NSArray* monthlyArray;
@property (strong, nonatomic)NSArray* yearlyArray;
@property (strong, nonatomic)NSArray* plannedArray;
@property (strong, nonatomic)NSArray* allArray;


@property (assign) NSInteger typeToShow;

@end

@implementation THEventManagementViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _manager = [THCoreDataManager sharedInstance];
    
    //set event type to show
    _typeToShow = 0;
}


-(void)viewWillAppear:(BOOL)animated
{
    [self initilizeArray];
    [self reloadData];
}

-(void)initilizeArray
{
    _dailyArray = [_manager getRegularEventsModelByType:THDAILYEVENT];
 //   NSLog(@"daily array count:%lu",(unsigned long)[_dailyArray count]);
    _weeklyArray = [_manager getRegularEventsModelByType:THWEEKLYEVENT];
   // NSLog(@"weekly array count:%lu",(unsigned long)[_weeklyArray count]);
    _monthlyArray = [_manager getRegularEventsModelByType:THMONTHLYEVENT];
    //NSLog(@"weekly array count:%lu",(unsigned long)[_weeklyArray count]);
    _yearlyArray = [_manager getRegularEventsModelByType:THYEARLYEVENT];
    //NSLog(@"weekly array count:%lu",(unsigned long)[_weeklyArray count]);
    _allArray = [[[_dailyArray arrayByAddingObjectsFromArray:_weeklyArray] arrayByAddingObjectsFromArray:_monthlyArray] arrayByAddingObjectsFromArray:_yearlyArray];
    //NSLog(@"all array count:%lu",(unsigned long)[_allArray count]);
}


-(void)reloadData
{
 //   NSLog(@"reload data!");
    [_scrollView removeFromSuperview];
    _scrollView = [[THManageScrollView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height-100)];
    NSArray* array = NULL;
    switch (_typeToShow) {
        case 0:
            array = _allArray;
            break;
        case 1:
            array = _dailyArray;
            break;
        case 2:
            array = _weeklyArray;
            break;
        case 3:
            array = _monthlyArray;
            break;
        default:
            break;
    }
    
    for (int i=0; i<[array count]; i++) {
       // NSLog(@"i = %d", i);
        THEventModelCellView* cell = [[THEventModelCellView alloc] init];
        EventModel* model = (EventModel*)[array objectAtIndex:i];
       // NSLog(@"Model %@ starts to update......", model.name);
        [cell setCellByEventModel:model];
        [_scrollView addEventModelCell:cell];
    }
    [self.view addSubview:_scrollView];
   
}

@end
