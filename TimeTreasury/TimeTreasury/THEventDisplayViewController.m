//
//  THEventDisplayViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 9/3/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventDisplayViewController.h"
#import "THCoreDataManager.h"
#import "THEventCellView.h"
#import "THNewEventViewController.h"
#import "THFileManager.h"
#import <Social/Social.h>
#import "THEventDetailViewController.h"

static const UITableViewRowAnimation animation = UITableViewRowAnimationLeft;
static const float quickStartViewWid = 180;
static const float quickStartViewHei = 538;
static const float quickStartViewX = 0;
static const float quickStartViewY = 30;


@interface THEventDisplayViewController ()
{
    BOOL shouldUpdateView;
    BOOL shouldShowNow;
    BOOL shouldShowTodo;
    BOOL shouldShowDone;
}

@property (assign) NSInteger eventCount;
@property (strong, nonatomic) NSMutableArray* eventsList;
@property (strong, nonatomic) THCoreDataManager* dataManager;
@property (strong, nonatomic) NSMutableArray* finishedEventsArray;
@property (strong, nonatomic) NSMutableArray* unfinishedEventsArray;
@property (strong, nonatomic) NSMutableArray* currentEventsArray;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (strong, nonatomic) NSIndexPath* indexPathForCurrentEvent;
@property (strong, nonatomic) UIView* shadowView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *right1Createnewevent;

@property (strong, nonatomic)PMCalendarController* pmCC;
@property (strong, nonatomic) NSString* typeToShow;
@property (assign) BOOL onlyShowFinished;
@property (strong, nonatomic)NSDate* startDate;
@property (strong, nonatomic)NSDate* endDate;
@property (strong, atomic)THEventCellView* currentCell;
@property (strong, nonatomic)THEventCellView* alertingView;

@property (strong, nonatomic)THFileManager* fileManager;
@property (strong,nonatomic) SLComposeViewController* slcComposeViewController;
@property (strong, nonatomic)THQuickStartTableViewController* quickStartViewController;
@end

@implementation THEventDisplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    shouldShowDone = shouldShowNow = shouldShowTodo = YES;
    
    UIBarButtonItem* left1Quicktart = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showQuickStartView:)];
    UIBarButtonItem* left2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    left2.width = 37;
    
    UIColor* color = [UIColor whiteColor];
    UIColor* tintColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    UIView* typeChooseView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 151, 30)];
    UIButton* nowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)];
    [nowButton setTitleColor:color forState:UIControlStateNormal];
    [nowButton setTitle:@"Now" forState:UIControlStateNormal];
    [nowButton.titleLabel setFont:[UIFont fontWithName:@"Helveticaneue" size:15]];
    [nowButton setBackgroundColor:tintColor];
    [nowButton addTarget:self action:@selector(typeChooseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    nowButton.layer.borderColor = [tintColor CGColor];
    nowButton.layer.borderWidth = 1;
    
    UIButton* todoButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 51, 30)];
    [todoButton setTitleColor:color forState:UIControlStateNormal];
    [todoButton setTitle:@"Todo" forState:UIControlStateNormal];
    [todoButton.titleLabel setFont:[UIFont fontWithName:@"Helveticaneue" size:15]];
    [todoButton setBackgroundColor:tintColor];
    [todoButton addTarget:self action:@selector(typeChooseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    todoButton.layer.borderColor = [tintColor CGColor];
    todoButton.layer.borderWidth = 1;
    
    UIButton* doneButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 51, 30)];
    [doneButton setTitleColor:color forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"Helveticaneue" size:15]];
    [doneButton setBackgroundColor:tintColor];
    [doneButton addTarget:self action:@selector(typeChooseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.layer.borderColor = [tintColor CGColor];
    doneButton.layer.borderWidth = 1;
    
    [typeChooseView addSubview:nowButton];
    [typeChooseView addSubview:todoButton];
    [typeChooseView addSubview:doneButton];
    typeChooseView.layer.borderWidth = 1;
    typeChooseView.layer.borderColor = [tintColor CGColor];
    typeChooseView.layer.cornerRadius = 4;
    typeChooseView.layer.masksToBounds = YES;
    
    
    UIBarButtonItem* left3Type = [[UIBarButtonItem alloc] initWithCustomView:typeChooseView];
    
    [self.navigationItem setLeftBarButtonItems:@[left1Quicktart,left2, left3Type]];
    
    shouldUpdateView = false;
    //get data manager
    _dataManager = [THCoreDataManager sharedInstance];
    //get notification when this view needs to be updated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSManagedObjectContextDidSaveNotification object:_dataManager.managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
    _fileManager = [THFileManager sharedInstance];
    
    
    //initilize table view
    _startDate = [THDateProcessor dateWithoutTime:[NSDate date]];
    _endDate = _startDate;

    [self updateDataWithDate:_startDate andEndDate:_endDate];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>0) {
        THEventCellView* eventCell = (THEventCellView*)cell;
        if (eventCell.timer) {
            //should invalidate timer here, or this cell will never be released
            [eventCell.timer invalidate];
        }
    }
    
}

-(void)typeChooseButtonTouched:(UIButton*)button
{
    UIColor* tintColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    if ([button.titleLabel.text isEqualToString:@"Now"]) {
        if (shouldShowNow) {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:tintColor forState:UIControlStateNormal];
        }
        else
        {
            button.backgroundColor = tintColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        shouldShowNow = !shouldShowNow;
        [self.tableView reloadData];
    }
    
    if ([button.titleLabel.text isEqualToString:@"Todo"]) {
        if (shouldShowTodo) {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:tintColor forState:UIControlStateNormal];
        }
        else
        {
            button.backgroundColor = tintColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        shouldShowTodo = !shouldShowTodo;
        [self.tableView reloadData];
    }
    
    if ([button.titleLabel.text isEqualToString:@"Done"]) {
        if (shouldShowDone) {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:tintColor forState:UIControlStateNormal];
        }
        else
        {
            button.backgroundColor = tintColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        shouldShowDone = !shouldShowDone;
        [self.tableView reloadData];
    }
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
    _finishedEventsArray = [[_dataManager getEventsFromDate:startDate toDate:endDate withStatus:FINISHED] mutableCopy];
    _unfinishedEventsArray = [[_dataManager getEventsByStatus:UNFINISHED] mutableCopy];
    _currentEventsArray = [[_dataManager getEventsFromDate:startDate toDate:endDate withStatus:CURRENT] mutableCopy];
}


#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return shouldShowNow?[_currentEventsArray count]:0;
        case 2:
            return shouldShowTodo?[_unfinishedEventsArray count]:0;
        case 3:
            return shouldShowDone?[_finishedEventsArray count]:0;
        default:
            return 0;
    }
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

#pragma mark - table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 34;
    }
    return CELL_HEIGHT;
}

#pragma mark - table view data source
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        UITableViewCell* titelCell = [[UITableViewCell alloc] init];
        UIButton* calendarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        calendarButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [calendarButton setImage:[UIImage imageNamed:@"Next"] forState:UIControlStateNormal];
        [calendarButton addTarget:self action:@selector(displayCalendarView:) forControlEvents:UIControlEventTouchUpInside];
        UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 232, 24)];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSString* startDatestr = [dateFormatter stringFromDate:_startDate];
        NSString* endDatestr = [dateFormatter stringFromDate:_endDate];
        if ([startDatestr isEqualToString:endDatestr]) {
            dateLabel.text = startDatestr;
        }
        else
        {
            dateLabel.text = [NSString stringWithFormat:@"%@ - %@", startDatestr, endDatestr];
        }
        
        [titelCell.contentView addSubview:calendarButton];
        [titelCell.contentView addSubview:dateLabel];
        titelCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return titelCell;
    }
    THEventCellView* cell = [[THEventCellView alloc] init];
    NSArray* eventsArray;
    switch (indexPath.section) {
        case 1:
            eventsArray = _currentEventsArray;
            break;
        case 2:
            eventsArray = _unfinishedEventsArray;
            break;
        case 3:
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
    NSDate* today = [THDateProcessor dateWithoutTime:[NSDate date]];
    Event* event = [_dataManager addEventWithGuid:guid withEventModel:eventModel withDay:today];
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:([_unfinishedEventsArray count])
                                                   inSection:2];
    
    if (today<=_endDate&&today>=_startDate) {
        [_unfinishedEventsArray addObject:event];
        if(shouldShowTodo){[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];}

    }
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
    THEventCellView* eventCell= (THEventCellView*)cell;
    NSIndexPath* path = [self.tableView indexPathForCell:eventCell];
    Event* event = eventCell.cellEvent;
    NSDate* today = [THDateProcessor dateWithoutTime:[NSDate date]];
    if (event.status.integerValue==CURRENT) {
        [_dataManager stopCurrentEvent];
     //   [todayCell updateCell];
        
        [_currentEventsArray removeObject:event];
        if(shouldShowNow) {
            [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:animation];
        }
        
        
        [_finishedEventsArray addObject:event];
        if(shouldShowDone)  {
            NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:[_finishedEventsArray count]-1 inSection:3];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
        }
        return;
    }
    
    
    if (event.status.integerValue==UNFINISHED) {
        [_dataManager startNewEvent:event];
        //[todayCell updateCell];
        
        if ([_currentEventsArray count]>0) {
            //[_currentCell updateCell];
            Event* currentEvent =[_currentEventsArray objectAtIndex:0];
            //update array
            [_currentEventsArray removeObject:currentEvent];
            //update cell if needed
            if (shouldShowNow) {
                NSIndexPath* currentPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.tableView deleteRowsAtIndexPaths:@[currentPath] withRowAnimation:animation];
            }
            
            //update array
            [_finishedEventsArray addObject:currentEvent];
            //update cell if needed
            if(shouldShowDone) {
                NSIndexPath* newPath = [NSIndexPath indexPathForRow:[_finishedEventsArray count]-1
                                                          inSection:3];
                [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:animation];
            }
        }
        
        //update array
        if (today>=_startDate&&today<=_endDate) {
            [_currentEventsArray addObject:event];
             //update cell if needed
            if(shouldShowNow) {
                NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
            }
        }
       
        
        
        //update array
        [_unfinishedEventsArray removeObject:event];
        //update cell if needed
        if(shouldShowTodo) {
            [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:animation];
        }
        return;
    }
    
    if(event.status.integerValue==FINISHED)
    {
        NSDate* today = [THDateProcessor dateWithoutTime:[NSDate date]];
        NSString* guid = [[NSUUID UUID] UUIDString];
        Event* event = [_dataManager addEventWithGuid:guid withEventModel:eventCell.cellEvent.eventModel withDay:today];
//        THEventCellView* view = [[THEventCellView alloc] init];
//        view.delegate = self;
//        [view setCellByEvent:event];
        if (today>=_startDate&&today<=_endDate) {
            [_unfinishedEventsArray addObject:event];
            if(shouldShowTodo){
                NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:([_unfinishedEventsArray count]-1)
                                                               inSection:2];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
            }
        }
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"TTAppStoryboard" bundle:nil];
    THEventCellView* cellView = (THEventCellView*)cell;
    THEventDetailViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"EventDetail"];
    controller.event = cellView.cellEvent;
    [self presentViewController:controller animated:YES completion:nil];
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
                case 1:
                    [_currentEventsArray removeObject:todelete];
                    [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:animation];
                    break;
                case 2:
                    [_unfinishedEventsArray removeObject:todelete];
                    [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:animation];
                    break;
                case 3:
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
            NSIndexPath* newIndex = [NSIndexPath indexPathForRow:[_unfinishedEventsArray count] inSection:2];
            switch (oldIndex.section) {
                case 1:
                    [_currentEventsArray removeObject:toRefresh];
                    [self.tableView deleteRowsAtIndexPaths:@[oldIndex] withRowAnimation:animation];
                    [_unfinishedEventsArray addObject:toRefresh];
                    [self.tableView insertRowsAtIndexPaths:@[newIndex] withRowAnimation:animation];
                    break;
                case 3:
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


-(void)calendarControllerDidDismissCalendar:(PMCalendarController *)calendarController
{
    PMPeriod* period = calendarController.period;
    _startDate = period.startDate;
    _endDate = period.endDate;
    NSLog(@"%@, end: %@", _startDate, _endDate);
    [self updateDataWithDate:_startDate andEndDate:_endDate];
    [self.tableView reloadData];
}


-(void)displayCalendarView:(id)sender
{
    _pmCC = [[PMCalendarController alloc] initWithThemeName:@"default"];
    _pmCC.delegate = self;
    _startDate = [NSDate date];
    _endDate = _startDate;
    [_pmCC presentCalendarFromRect:CGRectMake(72, 42, 0, 0)
                            inView:self.parentViewController.parentViewController.view
          permittedArrowDirections:PMCalendarArrowDirectionAny
                         isPopover:YES
                          animated:YES];
    NSLog(@"%f, %f, %f, %f", _pmCC.mainView.frame.origin.x,_pmCC.mainView.frame.origin.y,_pmCC.mainView.frame.size.width,_pmCC.mainView.frame.size.height);
}



@end
