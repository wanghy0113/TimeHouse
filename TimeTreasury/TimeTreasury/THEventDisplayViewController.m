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

static const UITableViewRowAnimation animation = UITableViewRowAnimationLeft;
static const float quickStartViewWid = 180;
static const float quickStartViewHei = 538;
static const float quickStartViewX = 0;
static const float quickStartViewY = 30;


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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *quickStartButton;
@property (strong, nonatomic) UIView* shadowView;


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
@property (strong, nonatomic)THQuickStartTableViewController* quickStartViewController;

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
    
    //quick start button
    _quickStartButton.target = self;
    _quickStartButton.action = @selector(showQuickStartView:);
    
    //initilize table view
    _startDate = [NSDate date];
    _endDate = _startDate;
    
    [self updateDataWithDate:_startDate andEndDate:_endDate];
    [self.tableView reloadData];
//    [self updateView];
}

-(void)viewWillAppear:(BOOL)animated
{
   // NSLog(@"current event name: %@", (Event*)[_dataManager currentEvent].eventModel.name);
    //get today's events(this function must be put in ViewWillAppear)
    if (shouldUpdateView) {
        [self updateDataWithDate:_startDate andEndDate:_endDate];
//        [self updateView];
        [self.tableView reloadData];
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


//-(void)updateView
//{
//    [_scrollView removeFromSuperview];
//    _scrollView = [[THDisplayScrollView alloc] initWithFrame:CGRectMake(0, 64,self.view.bounds.size.width, 455)];
//    [self.view addSubview:_scrollView];
//    
//    for(int i=0;i<[_currentEventsArray count];i++)
//    {
//        Event* event = (Event*)[_currentEventsArray objectAtIndex:i];
//        THEventCellView* cellView = [[THEventCellView alloc] init];
//        _currentCell = cellView;
//        cellView.delegate = self;
//        [cellView setCellByEvent:event];
//        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
//    }
//    for(int i=0;i<[_unfinishedEventsArray count];i++)
//    {
//        Event* event = (Event*)[_unfinishedEventsArray objectAtIndex:i];
//        THEventCellView* cellView = [[THEventCellView alloc] init];
//        cellView.delegate = self;
//        [cellView setCellByEvent:event];
//        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
//    }
//    for(int i=0;i<[_finishedEventsArray count];i++)
//    {
//        Event* event = (Event*)[_finishedEventsArray objectAtIndex:i];
//        THEventCellView* cellView = [[THEventCellView alloc] init];
//        cellView.delegate = self;
//        [cellView setCellByEvent:event];
//        [_scrollView addEventCell:cellView animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
//    }
//    
//}


#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_currentEventsArray count];
            break;
        case 1:
            return [_unfinishedEventsArray count];
        case 2:
            return [_finishedEventsArray count];
        default:
            return 0;
    }
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark - table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

#pragma mark - table view data source
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    THEventCellView* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    if (!cell) {
        cell = [[THEventCellView alloc] init];
    }
    NSArray* eventsArray;
    switch (indexPath.section) {
        case 0:
            eventsArray = _currentEventsArray;
            break;
        case 1:
            eventsArray = _unfinishedEventsArray;
            break;
        case 2:
            eventsArray = _finishedEventsArray;
            break;
        default:
            break;
    }
    
    Event* event = (Event*)[eventsArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell setCellByEvent:event];
    if (indexPath.section==0) {
        _currentCell = cell;
    }
    return cell;
}


#pragma mark - quick start delegate
-(void)quickStartDidSeletect:(UIView *)view eventModel:(EventModel *)eventModel
{
    NSString* guid = [[NSUUID UUID] UUIDString];
    Event* event = [_dataManager addEventWithGuid:guid withEventModel:eventModel withDate:nil];
    
    THEventCellView* cell = [[THEventCellView alloc] init];
    cell.delegate = self;
    [cell setCellByEvent:event];
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:([_unfinishedEventsArray count])
                                                   inSection:1];
    [_unfinishedEventsArray addObject:event];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
    NSLog(@"quick start!");
    //dismiss shadow view and quick start view
    [self tapOnShadow:nil];
}

#pragma mark - quik start button handler
-(void)showQuickStartView:(id)sender
{
    if (!_quickStartViewController) {
        _quickStartViewController = [[THQuickStartTableViewController alloc] init];
        [_quickStartViewController.view setFrame:CGRectMake(quickStartViewX, quickStartViewY, 0, quickStartViewHei)];
        _quickStartViewController.edgesForExtendedLayout = UIRectCornerAllCorners;
       
    }
     _quickStartViewController.delegate = self;
    [_quickStartViewController updateView];
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:self.parentViewController.view.frame];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha = 0;
        UITapGestureRecognizer* tapOnShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnShadow:)];
        [_shadowView addGestureRecognizer:tapOnShadow];
    }
   
    
    
    [self.parentViewController.parentViewController addChildViewController:_quickStartViewController];
    [self.parentViewController.parentViewController.view addSubview:_shadowView];
    [self.parentViewController.parentViewController.view addSubview:_quickStartViewController.view];
    
    [UIView animateWithDuration:0.4 animations:^(void)
    {
        [_quickStartViewController.view setFrame:CGRectMake(quickStartViewX, quickStartViewY, quickStartViewWid, quickStartViewHei)];
        [_shadowView setAlpha:0.5];
    }];
    
    
}

-(void)tapOnShadow:(UIGestureRecognizer*)gesture
{
    UIView* shadow = _shadowView;
    [UIView animateWithDuration:0.4 animations:^(void)
    {
        [_quickStartViewController.view setFrame:CGRectMake(quickStartViewX, quickStartViewY, 0, quickStartViewHei)];
        [shadow setAlpha:0];
    } completion:^(BOOL finished)
    {
        [_quickStartViewController removeFromParentViewController];
        [_quickStartViewController.view removeFromSuperview];
        [shadow removeFromSuperview];
    }];
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
    NSIndexPath* path = [self.tableView indexPathForCell:todayCell];
    Event* event = todayCell.cellEvent;
    if (event.status.integerValue==CURRENT) {
        [_dataManager stopCurrentEvent];
        [todayCell updateCell];
        
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:[_finishedEventsArray count] inSection:2];
        [_finishedEventsArray addObject:event];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
        
        [_currentEventsArray removeObject:event];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:animation];
        
        //remove from current array
        _currentCell = nil;
        return;
    }
    if (event.status.integerValue==UNFINISHED) {
        [_dataManager startNewEvent:event];
        [todayCell updateCell];
        
        if (_currentCell) {
            [_currentCell updateCell];
            NSIndexPath* oldPath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSIndexPath* newPath = [NSIndexPath indexPathForRow:([_finishedEventsArray count])
                                                      inSection:2];
            
            [_finishedEventsArray addObject:_currentCell.cellEvent];
            [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:animation];
            
            [_currentEventsArray removeObject:_currentCell.cellEvent];
            [self.tableView deleteRowsAtIndexPaths:@[oldPath] withRowAnimation:animation];
            
            _currentCell = nil;
        }
        
        _currentCell = todayCell;
        [_currentEventsArray addObject:event];
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
        
        [_unfinishedEventsArray removeObject:event];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:animation];
        return;
    }
    
    if(event.status.integerValue==FINISHED)
    {
        NSString* guid = [[NSUUID UUID] UUIDString];
        Event* event = [_dataManager addEventWithGuid:guid withEventModel:todayCell.cellEvent.eventModel withDate:todayCell.cellEvent.date];
        
        THEventCellView* view = [[THEventCellView alloc] init];
        view.delegate = self;
        [view setCellByEvent:event];
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:([_unfinishedEventsArray count])
                                                       inSection:1];
        [_unfinishedEventsArray addObject:event];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
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
            [_dataManager deleteEvent:_alertingView.cellEvent];
            Event* todelete = _alertingView.cellEvent;
            NSIndexPath* deleteIndex = [self.tableView indexPathForCell:_alertingView];
            switch (deleteIndex.section) {
                case 0:
                    [_currentEventsArray removeObject:todelete];
                    [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:animation];
                    break;
                case 1:
                    [_unfinishedEventsArray removeObject:todelete];
                    [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:animation];
                    break;
                case 2:
                    [_finishedEventsArray removeObject:todelete];
                    [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:animation];
                    break;
                    
                default:
                    break;
            }
            
        }
        
    }
    else if ([alertView.title isEqual:@"Refresh"]) {
        if (buttonIndex==0) {
            [_dataManager refreshEvent:_alertingView.cellEvent];
            [_alertingView updateCell];
            Event* toRefresh = _alertingView.cellEvent;
            NSIndexPath* oldIndex = [self.tableView indexPathForCell:_alertingView];
            NSIndexPath* newIndex = [NSIndexPath indexPathForRow:[_unfinishedEventsArray count] inSection:1];
            switch (oldIndex.section) {
                case 0:
                    [_currentEventsArray removeObject:toRefresh];
                    [self.tableView deleteRowsAtIndexPaths:@[oldIndex] withRowAnimation:animation];
                    [_unfinishedEventsArray addObject:toRefresh];
                    [self.tableView insertRowsAtIndexPaths:@[newIndex] withRowAnimation:animation];
                    break;
                case 2:
                    [_finishedEventsArray removeObject:toRefresh];
                    [self.tableView deleteRowsAtIndexPaths:@[oldIndex] withRowAnimation:animation];
                    [_unfinishedEventsArray addObject:toRefresh];
                    [self.tableView insertRowsAtIndexPaths:@[newIndex] withRowAnimation:animation];
                    break;

                    
                default:
                    break;
            }

            
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
