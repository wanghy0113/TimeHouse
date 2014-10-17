//
//  THTodayViewController.m
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THTodayViewController.h"
#import "Event.h"
#import "EventModel.h"
#import "THDateProcessor.h"


@interface THTodayViewController ()
@property (assign) NSInteger eventCount;
@property (strong, nonatomic) NSMutableArray* eventsList;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UITableView *activityTableView;

@property (strong, nonatomic) THCoreDataManager* dataManager;

@property (strong, nonatomic) NSMutableArray* finishedEventsArray;
@property (strong, nonatomic) NSMutableArray* unfinishedEventsArray;

@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (strong, nonatomic) NSIndexPath* indexPathForCurrentEvent;
@property (weak, nonatomic) NSTimer* timer;   //set timer to weak so that it can be released after calling "invalidate"
@property (strong, nonatomic)PMCalendarController* pmCC;
@property (strong, nonatomic) NSString* typeToShow;
@property (assign) BOOL onlyShowFinished;
@property (strong, nonatomic)NSDate* startDate;
@property (strong, nonatomic)NSDate* endDate;
@end

@implementation THTodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set view background
    UIImageView* bkView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bkView.image = [UIImage imageNamed:@"paperBackground.jpg"];
    [self.view addSubview:bkView];
    [self.view sendSubviewToBack:bkView];
    
    
    //get data manager
    _dataManager = [THCoreDataManager sharedInstance];
    
    //initilize table view
    _activityTableView.rowHeight = 60;
    [_activityTableView registerClass:[THTodayActivityCell class] forCellReuseIdentifier:@"activityCell"];
    _activityTableView.dataSource=self;
    _activityTableView.delegate=self;
    _activityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _activityTableView.backgroundColor = [UIColor clearColor];
    
    _startDate = [NSDate date];
    _endDate = _startDate;

}

-(void)viewWillAppear:(BOOL)animated
{
    
    //get today's event's(this function must be put in ViewWillAppear)
    [self updateViewWithStartDate:_startDate andEndDate:_endDate onlyFinished:NO];
    
}

-(void)updateViewWithStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate onlyFinished:(BOOL)only
{
    _onlyShowFinished = only;
    
    //set head title
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    if ([startDate compare:endDate]==NSOrderedSame) {
        _navigationBar.title = [_dateFormatter stringFromDate:startDate];
    }
    else
    {
        _navigationBar.title = [NSString stringWithFormat:@"%@ - %@",[_dateFormatter stringFromDate:startDate],[_dateFormatter stringFromDate:endDate]];
    }
    
    _finishedEventsArray = [[_dataManager getFinishedEventsFromDate:startDate toDate:endDate] mutableCopy];
    _unfinishedEventsArray = [[_dataManager getEventsByStatus:UNFINISHED] mutableCopy];

    [_activityTableView reloadData];
}



#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_onlyShowFinished) {
        return 1;
    }
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = [_finishedEventsArray count];
            break;
        case 1:
        {
            if (_dataManager.currentEvent) {
                numberOfRows = 1;
            }
              break;
        }
        case 2:
            numberOfRows = [_unfinishedEventsArray count];
        default:
            break;
    }
    return numberOfRows;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    THTodayActivityCell* cell = (THTodayActivityCell*)[tableView dequeueReusableCellWithIdentifier:@"activityCell"];
    cell.delegate = self;                                       //set cell's delegate
    NSInteger eventIndex = indexPath.row;
    Event* event = nil;
    switch (indexPath.section) {
        case 0:
        {
            event = [_finishedEventsArray objectAtIndex:eventIndex];
            [cell setCellByEvent:event];
            break;
        }
        case 1:
        {
            event = _dataManager.currentEvent;
            [cell setCellByEvent:event];
            _indexPathForCurrentEvent = indexPath;
            if (!_timer) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDuration:) userInfo:nil repeats:YES];
            }
            break;
        }
        case 2:
        {
            event = [_unfinishedEventsArray objectAtIndex:eventIndex];
            [cell setCellByEvent:event];
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableView delegate
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/*****************************************************************************************************************
 some bugs occur when deleting an event~~~~~~~
 *****************************************************************************************************************/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event* eventToBeDeleted = nil;
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        NSInteger section = indexPath.section;
        switch (section) {
            case 0:
            {   eventToBeDeleted = [_finishedEventsArray objectAtIndex:indexPath.row];
                [_finishedEventsArray removeObject:eventToBeDeleted];
                break;
            }
            case 1:
            {   eventToBeDeleted = _dataManager.currentEvent;
                [_unfinishedEventsArray removeObject:eventToBeDeleted];
                break;
            }
            case 2:
                eventToBeDeleted = [_unfinishedEventsArray objectAtIndex:indexPath.row];
            default:
                break;
        }
        [_dataManager deleteEvent:eventToBeDeleted];
        [_activityTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_activityTableView reloadData];   //can be optimazied
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    THTodayActivityCell* cell = (THTodayActivityCell*)[tableView cellForRowAtIndexPath:indexPath];

    THEventDetailViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetail"];
    viewController.event = cell.cellEvent;
    [self.navigationController pushViewController:viewController animated:YES];
}



#pragma timer handler
-(void)updateDuration:(id)sender
{
    NSDate* date = _dataManager.currentEvent.startTime;
    THTodayActivityCell* updatedCell = (THTodayActivityCell*)[_activityTableView cellForRowAtIndexPath:_indexPathForCurrentEvent];
    CGFloat intervalSeconds = [[NSDate date] timeIntervalSinceDate:date];
    updatedCell.duration.text = [THDateProcessor timeFromSecond:intervalSeconds withFormateDescriptor:@"hh:mm:ss"];
    [updatedCell.duration sizeToFit];
}

#pragma mark - THTodayActivityCell delegate
-(void)cellMarkTouched:(UITableViewCell *)cell
{
    NSLog(@"cell mark touched");
    THTodayActivityCell* todayCell = (THTodayActivityCell*)cell;
    Event* event = todayCell.cellEvent;
    if (event.status.integerValue==CURRENT) {
        [_timer invalidate];
        [_dataManager stopCurrentEvent];
        [todayCell setCellByEvent:event];
      //  NSLog(@"cell event after click stop: cell:%@, event:%@",cell, todayCell.cellEvent);
    }
    if (event.status.integerValue==UNFINISHED) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDuration:) userInfo:nil repeats:YES];
        }
        [_dataManager startNewEvent:event];
        [todayCell updateCell];
        THTodayActivityCell* currentCell = (THTodayActivityCell*)[_activityTableView cellForRowAtIndexPath:_indexPathForCurrentEvent];
        [currentCell updateCell];
        _indexPathForCurrentEvent = [_activityTableView indexPathForCell:cell];
    }
}
- (IBAction)ShowCalendar:(id)sender {
    _pmCC = [[PMCalendarController alloc] init];
    _pmCC.delegate = self;
    _pmCC.mondayFirstDayOfWeek = YES;
    
    NSLog(@"calendar button pressed with action:show calendar");
    //every time calendar is shown set the date to be today;
    _startDate = [NSDate date];
    _endDate = _startDate;
    [self updateViewWithStartDate:_startDate
                        andEndDate:_endDate
                     onlyFinished:NO];

    
    
    [_pmCC presentCalendarFromView:sender permittedArrowDirections:PMCalendarArrowDirectionAny animated:YES];
}

#pragma mark PMCalendarControllerDelegate method
- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{

    NSDate* startDate = newPeriod.startDate;
    NSDate* endDate = newPeriod.endDate;
    
    //determine whether today is within the selected period
    NSDate* lastTimeOfEndDate =  [[THDateProcessor getBoundaryDateBy:endDate] objectAtIndex:1];
    NSDate* firstTimeOfStartDate = [[THDateProcessor getBoundaryDateBy:startDate] objectAtIndex:0];
    NSDate* today = [NSDate date];
    _startDate = startDate;
    _endDate = endDate;
    
    //if today is within the period, show current and unfinished, if not, only show finished
    if ((!([today compare:firstTimeOfStartDate]==-1)) && (!([today compare:lastTimeOfEndDate]==1)) ) {
        [self updateViewWithStartDate:startDate andEndDate:endDate onlyFinished:NO];
    }
    else
    {
        [self updateViewWithStartDate:startDate andEndDate:endDate onlyFinished:YES];
    }
    
    NSLog(@"calendar date changed with start date:%@, end date:%@",startDate,endDate);
    
}
@end
