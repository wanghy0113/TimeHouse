#import "THTimeAnalysisViewController.h"









@interface THTimeAnalysisViewController ()
{
     BOOL shouldUpdateView;
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
@end

@implementation THTimeAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    shouldUpdateView = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreChanged:) name:NSManagedObjectContextDidSaveNotification object:[THCoreDataManager sharedInstance].managedObjectContext];
    
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
    
    [self initilizeData];
    
    for (int i=0; i<[_data count]; i++) {
        THCategoryLabelView* labelView = [[THCategoryLabelView alloc] initWithCategory:[_strings objectAtIndex:i]
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

-(void)addToUsed:(UIView*)labelView
{
    [UIView animateWithDuration:0.2 animations:^(void){
            [labelView setFrame:CGRectMake(self.view.bounds.size.width-labelView.bounds.size.width, nextLegendY, labelView.bounds.size.width, labelView.bounds.size.height)];
    }];
    nextLegendY+=labelView.bounds.size.height+5;
    [_sliceIndex addObject:[NSNumber numberWithInteger:labelView.tag-800]];
}


-(void)addToUnused:(UIView*)labelView
{
    if (nextLabelX+labelView.bounds.size.width>_unusedCategoryView.bounds.size.width) {
        nextLabelX = self.unusedCategoryView.frame.origin.x;
        nextLabelY+=labelView.bounds.size.height+5;
    }
    
    [UIView animateWithDuration:0.2 animations:^(void){
        [labelView setFrame:CGRectMake(nextLabelX, nextLabelY, labelView.bounds.size.width, labelView.bounds.size.height)];
    }];
    nextLabelX += labelView.bounds.size.width+5;
    [_sliceIndex removeObjectIdenticalTo:[NSNumber numberWithInteger:labelView.tag-800]];
}

-(void)paneStart:(UIPanGestureRecognizer*)pane
{
    if (pane.state==UIGestureRecognizerStateBegan) {
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
            [self addToUsed:pane.view];
            [self.pieChart reloadData];
        }
        else
        {
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
            self.unusedCategoryView.backgroundColor = [UIColor grayColor];
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
    
    NSDictionary* catDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
    NSArray* categories = catDic.allKeys;
    NSDictionary* dic = [THTimeAnalysisEngine getPercentagesByCategories:categories];
    NSLog(@"dic: %@", dic);
    [_data removeAllObjects];
    [_color removeAllObjects];
    [_strings removeAllObjects];
    for(NSString* c in categories)
    {
        [_strings addObject:c];
        [_data addObject:[dic objectForKey:c]];
        [_color addObject:[THColorPanel getColorFromCategory:c]];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (shouldUpdateView) {
        [self initilizeData];
        [self.pieChart reloadData];
        shouldUpdateView = false;
    }
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
