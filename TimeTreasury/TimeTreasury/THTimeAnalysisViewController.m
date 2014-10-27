#import "THTimeAnalysisViewController.h"
#import "NSDate+Helpers.h"








@interface THTimeAnalysisViewController ()
{
     BOOL shouldUpdateView;
    int dateRowToPick;
    CGFloat paneViewOriginX;
    CGFloat paneViewOriginY;
    CGFloat minxChart;
    CGFloat minyChart;
    CGFloat maxxChart;
    CGFloat maxyChart;
    CGFloat minxUnused;
    CGFloat minyUnused;
    CGFloat maxxUnused;
    CGFloat maxyUnused;
    CGFloat nextLabelX;
    CGFloat nextLabelY;
    CGFloat nextLegendY;
}
@property (strong, nonatomic)NSMutableArray* data;
@property (strong, nonatomic)NSMutableArray* color;
@property (strong, nonatomic)NSMutableArray* strings;
@property (strong, nonatomic)NSMutableArray* sliceIndex;
@property (strong, nonatomic)NSMutableArray* usedViewArray;
@property (strong, nonatomic)NSMutableArray* unusedViewArray;
@property (strong, nonatomic)THDatePickView* datePickerView;
@property (strong, nonatomic)NSDate* startDate;
@property (strong, nonatomic)NSDate* endDate;
@property (strong, nonatomic)NSDateFormatter* dateFormatter;
@end

@implementation THTimeAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [_changeStartTimeButton addTarget:self action:@selector(changeStartTime:) forControlEvents:UIControlEventTouchUpInside];
    [_changeEndTimeButton addTarget:self action:@selector(changeEndTime:) forControlEvents:UIControlEventTouchUpInside];
    
    _datePickerView = [[THDatePickView alloc] init];
    [_datePickerView.datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    _datePickerView.delegate = self;
    [_datePickerView.datePicker setMaximumDate:[NSDate date]];
    [self.view addSubview:_datePickerView];
    
    shouldUpdateView = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSManagedObjectContextDidSaveNotification object:[THCoreDataManager sharedInstance].managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
    [self.pieChart setDataSource:self];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setAnimationSpeed:1.0];
    [self.pieChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:20]];
    [self.pieChart setLabelRadius:60];
    self.pieChart.showLabel = YES;
    [self.pieChart setPieRadius:120];
    [self.pieChart setShowPercentage:YES];
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChart setPieCenter:CGPointMake(125, 125)];
    [self.pieChart setUserInteractionEnabled:YES];
    [self.pieChart setLabelShadowColor:[UIColor blackColor]];
    
    
    minxChart = self.pieChart.frame.origin.x;
    minyChart = self.pieChart.frame.origin.y;
    maxxChart = minxChart+self.pieChart.frame.size.width;
    maxyChart = minyChart+self.pieChart.frame.size.height;
    
    minxUnused = self.unusedCategoryView.frame.origin.x;
    minyUnused= self.unusedCategoryView.frame.origin.y;
    maxxUnused = minxUnused+self.unusedCategoryView.frame.size.width;
    maxyUnused = minyUnused+self.unusedCategoryView.frame.size.height;
    
    nextLabelX = self.unusedCategoryView.frame.origin.x;
    nextLabelY = self.unusedCategoryView.frame.origin.y;
    nextLegendY = _pieChart.frame.origin.y;
    
    _data = [[NSMutableArray alloc] init];
    _color = [[NSMutableArray alloc] init];
    _strings = [[NSMutableArray alloc] init];
    _sliceIndex = [[NSMutableArray alloc] init];
    
    
    _usedViewArray = [[NSMutableArray alloc] init];
    _unusedViewArray = [[NSMutableArray alloc] init];
    

}


-(void)changeStartTime:(id)sender
{
    dateRowToPick = 0;
    [UIView animateWithDuration:0.3 animations:^(void)
    {
        [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, 320, datePickerViewHeight)];
    }];
    [_datePickerView.datePicker setDate:_startDate animated:NO];
    [_startTimeLabel sizeToFit];
    _startTimeLabel.layer.borderWidth = 1;
    [_changeStartTimeButton setEnabled:NO];
    [_changeEndTimeButton setEnabled:NO];
    
}

-(void)changeEndTime:(id)sender
{
    dateRowToPick = 1;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, 320, datePickerViewHeight)];
     }];
    [_datePickerView.datePicker setDate:_endDate animated:NO];
    [_endTimeLabel sizeToFit];
    _endTimeLabel.layer.borderWidth = 1;
    [_changeStartTimeButton setEnabled:NO];
    [_changeEndTimeButton setEnabled:NO];
}

-(void)finishPickingDate:(NSDate *)date
{
    NSLog(@"finish!");
    if (dateRowToPick==0) {
        _startDate = [date dateWithoutTime];
        _startTimeLabel.layer.borderWidth = 0;
        
    }
    else if(dateRowToPick==1)
    {
        _endDate = [date dateWithoutTime];
        _endTimeLabel.layer.borderWidth = 0;
    }
    dateRowToPick = -1;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [_datePickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
     }];
    [_changeStartTimeButton setEnabled:YES];
    [_changeEndTimeButton setEnabled:YES];
    if (shouldUpdateView) {
        [self initilizeData];
        [self.pieChart reloadData];
        shouldUpdateView = false;
    }
}

-(void)dateValueChanged:(NSDate *)date
{
    if(dateRowToPick==0)
    {
        _startTimeLabel.text = [_dateFormatter stringFromDate:[date dateWithoutTime]];
        [_startTimeLabel sizeToFit];
    }
    else if (dateRowToPick==1)
    {
        _endTimeLabel.text = [_dateFormatter stringFromDate:[date dateWithoutTime]];
        [_endTimeLabel sizeToFit];
    }
    shouldUpdateView = YES;
}

-(void)addToUsed:(UIView*)labelView
{
    [UIView animateWithDuration:0.2 animations:^(void){
            [labelView setFrame:CGRectMake(self.view.bounds.size.width-labelView.bounds.size.width, nextLegendY, labelView.bounds.size.width, labelView.bounds.size.height)];
    }];
    nextLegendY+=labelView.bounds.size.height+5;
    [_usedViewArray addObject:labelView];
    [_sliceIndex addObject:[NSNumber numberWithInteger:labelView.tag-800]];
}


-(void)addToUnused:(UIView*)labelView
{
    
    if (nextLabelX+labelView.bounds.size.width>_unusedCategoryView.bounds.size.width) {
        nextLabelX = self.unusedCategoryView.frame.origin.x;
        nextLabelY+=labelView.bounds.size.height+5;
    }
    
    [UIView animateWithDuration:0.2 animations:^(void){
        CGFloat x = nextLabelX;
        CGFloat y = nextLabelY;
        [labelView setFrame:CGRectMake(x, y, labelView.bounds.size.width, labelView.bounds.size.height)];
    }];
    nextLabelX += labelView.bounds.size.width+5;
    [_unusedViewArray addObject:labelView];
    [_sliceIndex removeObjectIdenticalTo:[NSNumber numberWithInteger:labelView.tag-800]];
}

-(void)deleteFromUsed:(UIView*)view
{
    NSInteger index = [_usedViewArray indexOfObject:view];
    if (index==0) {
        nextLegendY = _pieChart.frame.origin.y;
    }
    else
    {
        UIView* lastView = [_usedViewArray objectAtIndex:index-1];
        nextLegendY = lastView.frame.origin.y+lastView.frame.size.height+5;
    }
    for (NSInteger i=index+1; i<[_usedViewArray count]; i++) {
        NSLog(@"move index: %ld", i);
        UIView* labelView = (UIView*)[_usedViewArray objectAtIndex:i];
        CGFloat y = nextLegendY;
        [UIView animateWithDuration:0.2 animations:^(void){
            
            [labelView setFrame:CGRectMake(self.view.bounds.size.width-labelView.bounds.size.width, y, labelView.bounds.size.width, labelView.bounds.size.height)];
        }];
        nextLegendY+=labelView.bounds.size.height+5;
    }
    [_usedViewArray removeObject:view];
}

-(void)deleteFromUnused:(UIView*)view
{
    NSInteger index = [_unusedViewArray indexOfObject:view];
    if (index==0) {
        nextLabelX = self.unusedCategoryView.frame.origin.x;
        nextLabelY = self.unusedCategoryView.frame.origin.y;
    }
    else
    {
        UIView* lastView = [_unusedViewArray objectAtIndex:index-1];
        nextLabelX = lastView.frame.origin.x+lastView.frame.size.width+5;
        nextLabelY = lastView.frame.origin.y;
    }
    
    
    for (NSInteger i=index+1; i<[_unusedViewArray count]; i++) {
        UIView* labelView = (UIView*)[_unusedViewArray objectAtIndex:i];
        if (nextLabelX+labelView.bounds.size.width>_unusedCategoryView.bounds.size.width) {
            nextLabelX = self.unusedCategoryView.frame.origin.x;
            nextLabelY+=labelView.bounds.size.height+5;
        }
        
        [UIView animateWithDuration:0.2 animations:^(void){
            [labelView setFrame:CGRectMake(nextLabelX, nextLabelY, labelView.bounds.size.width, labelView.bounds.size.height)];
        }];
        nextLabelX += labelView.bounds.size.width+5;
    }
    [_unusedViewArray removeObject:view];
}

-(void)paneStart:(UIPanGestureRecognizer*)pane
{
    if (pane.state==UIGestureRecognizerStateBegan) {
        NSLog(@"start: pane x %f pane y %f",pane.view.frame.origin.x,pane.view.frame.origin.y);
        paneViewOriginX = pane.view.frame.origin.x;
        paneViewOriginY = pane.view.frame.origin.y;
    }
    
    if (pane.state==UIGestureRecognizerStateEnded) {
        if (self.pieChart.alpha>0.6&&[self.unusedCategoryView.backgroundColor isEqual:[UIColor whiteColor]]) {
            [UIView animateWithDuration:0.3 animations:^(void)
             {
                 [pane.view setFrame:CGRectMake(paneViewOriginX, paneViewOriginY, pane.view.frame.size.width, pane.view.frame.size.height)];
             }];
        }
        else if(self.pieChart.alpha<0.6)
        {
            [self deleteFromUnused:pane.view];
            [self addToUsed:pane.view];
            [self.pieChart reloadData];
        }
        else
        {
            [self deleteFromUsed:pane.view];
            [self addToUnused:pane.view];
            [self.pieChart reloadData];
        }
        self.pieChart.alpha = 1;
        self.unusedCategoryView.backgroundColor = [UIColor whiteColor];
        return;
    }
    CGPoint point = [pane translationInView:[pane.view superview]];
    [pane.view setFrame:CGRectMake(paneViewOriginX+point.x, paneViewOriginY+point.y, pane.view.frame.size.width, pane.view.frame.size.height)];
    CGFloat x = pane.view.frame.origin.x;
    CGFloat y = pane.view.frame.origin.y;
    if ([_sliceIndex containsObject:[NSNumber numberWithInteger:pane.view.tag-800]]) {
        if (x<maxxUnused&&x>minxUnused&&y<maxyUnused&&y>minyUnused) {
            self.unusedCategoryView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
        else
        {
            self.unusedCategoryView.backgroundColor = [UIColor whiteColor];
        }
    }
    else
    {
        if (x<maxxChart&&x>minxChart&&y<maxyChart&&y>minyChart) {
            self.pieChart.alpha = 0.5;
        }
        else
        {
            self.pieChart.alpha = 1;
        }
    }
   
}



-(void)initilizeData
{
    
    NSArray* catArray = [THSettingFacade getActiveCategories];
    NSArray* array = [THTimeAnalysisEngine getPercentagesByCategories:catArray withStartDate:_startDate
                                                               andEndDate:_endDate];
    [_data removeAllObjects];
    [_color removeAllObjects];
    [_strings removeAllObjects];
    [_sliceIndex removeAllObjects];
    for (UIView* view in _unusedViewArray) {
        [view removeFromSuperview];
    }
    for (UIView* view in _usedViewArray) {
        [view removeFromSuperview];
    }
    nextLabelX = self.unusedCategoryView.frame.origin.x;
    nextLabelY = self.unusedCategoryView.frame.origin.y;
    nextLegendY = _pieChart.frame.origin.y;
    
    [_unusedViewArray removeAllObjects];
    [_usedViewArray removeAllObjects];
    
    for(int i=0;i<[catArray count];i++)
    {
        NSNumber* n = [catArray objectAtIndex:i];
        [_strings addObject:[THSettingFacade categoryString:n.integerValue onlyActive:YES]];
        [_data addObject:[array objectAtIndex:i]];
        [_color addObject:[THSettingFacade categoryColor:n.integerValue onlyActive:YES]];
    }
    
    for (int i=0; i<[catArray count]; i++) {
        NSNumber* n = [catArray objectAtIndex:i];
        THCategoryLabelView* labelView = [[THCategoryLabelView alloc] initWithCategory:n.integerValue
                                                                               andType:THCategoryLabelTypeAdd];
        labelView.tag = 800+i;
        [self.view addSubview:labelView];
        float data = ((NSNumber*)[_data objectAtIndex:i]).floatValue;
        if (data>0.0) {
            UIPanGestureRecognizer* pane = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paneStart:)];
            [labelView addGestureRecognizer:pane];
            [self addToUsed:labelView];
        }
        else
        {
            labelView.alpha = 0.5;
            [self addToUnused:labelView];
        }
    }


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dateRowToPick = -1;
    NSDate* today = [NSDate date];
    _endDate = [today dateWithoutTime];
    _startDate = [today dateByAddingDays:-7];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    _startTimeLabel.text = [_dateFormatter stringFromDate:_startDate];
    [_startTimeLabel sizeToFit];
    _endTimeLabel.text = [_dateFormatter stringFromDate:_endDate];
    [_endTimeLabel sizeToFit];
    _startTimeLabel.layer.borderColor = [[UIColor orangeColor] CGColor];
    _endTimeLabel.layer.borderColor = [[UIColor orangeColor] CGColor];
    [_datePickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    [_changeStartTimeButton setEnabled:YES];
    [_changeEndTimeButton setEnabled:YES];
    [self initilizeData];
    [self.pieChart reloadData];
    shouldUpdateView = false;
}

#pragma mark - XYPieChart data source
-(NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [_sliceIndex count];
}

-(CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    int i = ((NSNumber*)[_sliceIndex objectAtIndex:index]).intValue;
    
    return ((NSNumber*)[_data objectAtIndex:i]).floatValue;
}

-(UIColor*)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    int i = ((NSNumber*)[_sliceIndex objectAtIndex:index]).intValue;
    return [_color objectAtIndex:i];
}

#pragma  mark - core date notification handler
-(void)dataStoreChanged:(id)sender
{
    shouldUpdateView = true;
}
@end
