//
//  THEventDisplayViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 9/3/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventDisplayViewController.h"
#import "THCoreDataManager.h"

#import "THDisplayScrollView.h"
#import "THEventCellView.h"
#import "THNewEventViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "THFileManager.h"
#import <Social/Social.h>
@interface THEventDisplayViewController ()
{
    BOOL shouldUpdateView;
}

@property (assign) NSInteger eventCount;
@property (strong, nonatomic) NSMutableArray* eventsList;
@property (strong, nonatomic) THCoreDataManager* dataManager;
@property (strong, nonatomic) NSMutableArray* finishedEventsArray;
@property (strong, nonatomic) NSMutableArray* unfinishedEventsArray;
@property (strong, nonatomic) NSMutableArray* currentEventsArray;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (strong, nonatomic) NSIndexPath* indexPathForCurrentEvent;

@property (strong, nonatomic)PMCalendarController* pmCC;
@property (strong, nonatomic) NSString* typeToShow;
@property (assign) BOOL onlyShowFinished;
@property (strong, nonatomic)NSDate* startDate;
@property (strong, nonatomic)NSDate* endDate;
@property (strong, atomic)THEventCellView* currentCell;
@property (strong, nonatomic)THDisplayScrollView* scrollView;
@property (strong, nonatomic)THEventCellView* alertingView;

@property (strong, nonatomic)THFileManager* fileManager;
@property (strong,nonatomic) SLComposeViewController* slcComposeViewController;

@end

@implementation THEventDisplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    shouldUpdateView = false;
    //get data manager
    _dataManager = [THCoreDataManager sharedInstance];
    //get notification when this view needs to be updated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSManagedObjectContextDidSaveNotification object:_dataManager.managedObjectContext];
    _fileManager = [THFileManager sharedInstance];
    
    
    //initilize table view
    _startDate = [NSDate date];
    _endDate = _startDate;
    
    [self updateDataWithDate:_startDate andEndDate:_endDate];
    [self updateView];
}

-(void)viewWillAppear:(BOOL)animated
{
   // NSLog(@"current event name: %@", (Event*)[_dataManager currentEvent].eventModel.name);
    //get today's events(this function must be put in ViewWillAppear)
    if (shouldUpdateView) {
        [self updateDataWithDate:_startDate andEndDate:_endDate];
        [self updateView];
        shouldUpdateView = false;
    }
    
    
}

-(void)updateDataWithDate:(NSDate*)startDate andEndDate:(NSDate*)endDate
{
    
    //set head title
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    _finishedEventsArray = [[_dataManager getFinishedEventsFromDate:startDate toDate:endDate] mutableCopy];
    _unfinishedEventsArray = [[_dataManager getEventsByStatus:UNFINISHED] mutableCopy];
    _currentEventsArray = [[_dataManager getEventsByStatus:CURRENT] mutableCopy];
}


-(void)updateView
{
    [_scrollView removeFromSuperview];
    _scrollView = [[THDisplayScrollView alloc] initWithFrame:CGRectMake(0, 64,self.view.bounds.size.width, 455)];
    [self.view addSubview:_scrollView];
    
    for(int i=0;i<[_currentEventsArray count];i++)
    {
        Event* event = (Event*)[_currentEventsArray objectAtIndex:i];
        THEventCellView* cellView = [[THEventCellView alloc] init];
        _currentCell = cellView;
        cellView.delegate = self;
        [cellView setCellByEvent:event];
        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
    }
    for(int i=0;i<[_unfinishedEventsArray count];i++)
    {
        Event* event = (Event*)[_unfinishedEventsArray objectAtIndex:i];
        THEventCellView* cellView = [[THEventCellView alloc] init];
        cellView.delegate = self;
        [cellView setCellByEvent:event];
        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
    }
    for(int i=0;i<[_finishedEventsArray count];i++)
    {
        Event* event = (Event*)[_finishedEventsArray objectAtIndex:i];
        THEventCellView* cellView = [[THEventCellView alloc] init];
        cellView.delegate = self;
        [cellView setCellByEvent:event];
        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
    }
    
}

#pragma  mark - core date notification handler
-(void)dataStoreChanged:(id)sender
{
    shouldUpdateView = true;
}


#pragma mark - THEventCell delegate
-(void)eventButtonTouched:(UIView *)cell
{
    THEventCellView* todayCell = (THEventCellView*)cell;
    Event* event = todayCell.cellEvent;
    if (event.status.integerValue==CURRENT) {
        [_dataManager stopCurrentEvent];
        [todayCell updateCell];
        return;
    
    }
    if (event.status.integerValue==UNFINISHED) {
        [_dataManager startNewEvent:event];
        [todayCell updateCell];
        [_currentCell updateCell];
        _currentCell = todayCell;
        return;
    }
    if(event.status.integerValue==FINISHED)
    {
        NSString* guid = [[NSUUID UUID] UUIDString];
        Event* event = [_dataManager addEventWithGuid:guid withEventModel:todayCell.cellEvent.eventModel withDate:todayCell.cellEvent.date];
        [_unfinishedEventsArray addObject:event];
        THEventCellView* view = [[THEventCellView alloc] init];
        view.delegate = self;
        [view setCellByEvent:event];
        [_scrollView addEventCell:view animation:YES initialFrame:view.frame];
        return;
    }
}

-(void)deleteButtonTouched:(UIView *)cell
{
    _alertingView = (THEventCellView*)cell;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                    message:@"Are you sure?"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
    [alert show];
    
}

-(void)editButtonTouched:(UIView *)cell
{
    
}

-(void)shareButtonTouched:(UIView *)cell
{
   _alertingView = (THEventCellView*)cell;
    // Check if the Facebook app is installed and we can present the share dialog
    UIImage* image = _alertingView.activityIcon.image;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        _slcComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [_slcComposeViewController addImage:image];
        [_slcComposeViewController setInitialText:[_alertingView convertEventToMessage]];
        [self presentViewController:_slcComposeViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Account Found" message:@"Configure a face book account in setting" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(void)refreshButtonTouched:(UIView *)cell
{
    _alertingView = (THEventCellView*)cell;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Refresh"
                                                    message:@"Are you sure?"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
    [alert show];
}

#pragma alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqual:@"Delete"]) {
        if (buttonIndex==0) {
            [_scrollView deleteEventCell:_alertingView];
            [_dataManager deleteEvent:_alertingView.cellEvent];
        }
        
    }
    else if ([alertView.title isEqual:@"Refresh"]) {
        if (buttonIndex==0) {
            [_dataManager refreshEvent:_alertingView.cellEvent];
            [_alertingView updateCell];
        }
        
    }
    _alertingView = nil;
}
-(void)displayCalendarView:(UIGestureRecognizer*)gesture
{
    _pmCC = [[PMCalendarController alloc] init];
    _pmCC.delegate = self;
    _pmCC.mondayFirstDayOfWeek = YES;
    _startDate = [NSDate date];
    _endDate = _startDate;
   // [self updateViewWithStartDate:_startDate andEndDate:_endDate onlyFinished:NO];
    [_pmCC presentCalendarFromView:gesture.view permittedArrowDirections:PMCalendarArrowDirectionAny animated:YES];
    
}



@end
