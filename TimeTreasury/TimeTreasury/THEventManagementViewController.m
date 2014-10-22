//
//  THEventManagementViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 6/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventManagementViewController.h"

static const CGFloat topBaroffset = 20;
@interface THEventManagementViewController ()
{
    BOOL shouldUpdateView;
}

@property (strong, nonatomic)THCoreDataManager* dataManager;

@property (strong, nonatomic)THManageScrollView* scrollView;
@property (strong, nonatomic)NSMutableArray* dailyArray;
@property (strong, nonatomic)NSMutableArray* weeklyArray;
@property (strong, nonatomic)NSMutableArray* monthlyArray;
@property (strong, nonatomic)NSMutableArray* quickStartArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) THCategoryPickerView* categoryPickerView;
@property (strong, nonatomic) IBOutlet UIButton *changeTypeButton;
@property (strong, nonatomic) IBOutlet UIButton *changeCategoryButton;
@property (assign) NSInteger typeToShow;
@property (strong, nonatomic)NSArray* typeArray;
@property (strong, nonatomic) NSString* category;
@end

@implementation THEventManagementViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    _dataManager = [THCoreDataManager sharedInstance];
    shouldUpdateView = false;
    
    _categoryPickerView = [[THCategoryPickerView alloc] initWithAllOption:YES];
    [_categoryPickerView setFrame:CGRectMake(0, categoryPickerViewHidenY, 320, 162)];
    _categoryPickerView.delegate = self;
    _category = @"All";
    [self.view addSubview:_categoryPickerView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSManagedObjectContextDidSaveNotification object:_dataManager.managedObjectContext];
    
    //set type label and category label
    _typeLabel.text = @"All";
    _categoryLabel.attributedText = [self getCategoryAllString];

   // self.collectionView.collectionViewLayout set
    //set event type to show
    _typeToShow = 0;
    _typeArray = @[@"All",@"Daily",@"Weekly",@"Monthly",@"Quick Start"];
    [self.collectionView registerClass:[THEventModelCellView class] forCellWithReuseIdentifier:@"EventModelCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [self initilizeArray];
    [self.collectionView reloadData];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    if (shouldUpdateView) {
        [self initilizeArray];
        [self.collectionView reloadData];
        shouldUpdateView = false;
    }
   
}

-(NSAttributedString*)getCategoryAllString
{
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:@"All"
                                                                 attributes:@{NSForegroundColorAttributeName:_typeLabel.textColor,NSFontAttributeName:_typeLabel.font}];
    return string;
}

-(void)initilizeArray
{
    NSLog(@"category: %@",_category);
    if ([_category isEqualToString:@"All"]) {
        _dailyArray = [[_dataManager getRegularEventsModelByType:THDAILYEVENT] mutableCopy];
        _weeklyArray = [[_dataManager getRegularEventsModelByType:THWEEKLYEVENT] mutableCopy];
        _monthlyArray = [[_dataManager getRegularEventsModelByType:THMONTHLYEVENT] mutableCopy];
    }
    else
    {
        _dailyArray = [[_dataManager getEventModelsByType:THDAILYEVENT andCategory:_category] mutableCopy];
        _weeklyArray = [[_dataManager getEventModelsByType:THWEEKLYEVENT andCategory:_category] mutableCopy];
        _monthlyArray =[[_dataManager getEventModelsByType:THMONTHLYEVENT andCategory:_category] mutableCopy];
    }
    /*
     get not regular events in quick start list
     */
    _quickStartArray = [[NSMutableArray alloc] init];
    NSArray* array = [_dataManager getQuickStartEventModel];
    for (int i=0; i<[array count]; i++) {
        EventModel* eventModel = [array objectAtIndex:i];
        if ((eventModel.type.integerValue == THCASUALEVENT||eventModel.type.integerValue==THPLANNEDEVENT)&&([_category isEqualToString:@"All"]||[eventModel.catogery isEqualToString:_category]))
        {
            [_quickStartArray addObject:eventModel];
        }
    }
}


#pragma mark - collection view data source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_typeToShow==0) {
        return 4;
    }
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_typeToShow==0) {
        switch (section) {
            case 0:
                return [_dailyArray count];
                break;
            case 1:
                return [_weeklyArray count];
                break;
            case 2:
                return [_monthlyArray count];
                break;
            case 3:
                return [_quickStartArray count];
                break;
            default:
                break;
        }
    }
    switch (_typeToShow) {
        case 1:
            return [_dailyArray count];
            break;
        case 2:
            return [_weeklyArray count];
            break;
        case 3:
            return [_monthlyArray count];
            break;
        case 4:
            return [_quickStartArray count];
            break;
        default:
            break;
    }
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    THEventModelCellView* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventModelCell" forIndexPath:indexPath];

    NSArray* array = nil;
    
    if (_typeToShow==0) {
        switch (indexPath.section) {
            case 0:
                array = _dailyArray;
                break;
            case 1:
                array = _weeklyArray;
                break;
            case 2:
                array = _monthlyArray;
                break;
            case 3:
                array = _quickStartArray;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (_typeToShow) {
            case 1:
                array = _dailyArray;
                break;
            case 2:
                array = _weeklyArray;
                break;
            case 3:
                array = _monthlyArray;
                break;
            case 4:
                array = _quickStartArray;
                break;
            default:
                break;
        }
    }
    
    
    NSInteger eventModelIndex = indexPath.item;
    [cell setCellByEventModel:[array objectAtIndex:eventModelIndex]];
    
    return cell;
}


- (IBAction)changeType:(id)sender {
    switch (_typeToShow) {
        case 0:
            _typeToShow = 1;
            break;
        case 1:
            _typeToShow = 2;
            break;
        case 2:
            _typeToShow = 3;
            break;
        case 3:
            _typeToShow = 4;
            break;
        case 4:
            _typeToShow = 0;
            break;
        default:
            break;
    }
    _typeLabel.text = [_typeArray objectAtIndex:_typeToShow];
    [_collectionView reloadData];
}

- (IBAction)changeCategory:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        [_categoryPickerView setFrame:CGRectMake(0, categoryPickerViewShownY, _categoryPickerView.bounds.size.width, _categoryPickerView.bounds.size.height)];}];
    [_changeCategoryButton setEnabled:NO];
    
    
}

#pragma mark - THCategoryPickerView delegate
-(void)CatetoryPickerView:(UIView *)view valueChanged:(NSAttributedString *)catogery
{
    _categoryLabel.attributedText = catogery;
}

-(void)CatetoryPickerView:(UIView *)view finishPicking:(NSAttributedString *)catogery
{
    [UIView animateWithDuration:0.5 animations:^{
        [_categoryPickerView setFrame:CGRectMake(0, categoryPickerViewHidenY, _categoryPickerView.bounds.size.width, _categoryPickerView.bounds.size.height)];}];
    [_changeCategoryButton setEnabled:YES];
    _category = [catogery string];
    [self initilizeArray];
    [_collectionView reloadData];
}


#pragma  mark - core date notification handler
-(void)dataStoreChanged:(id)sender
{
    shouldUpdateView = true;
}


@end
