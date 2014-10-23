#import "THTimeAnalysisViewController.h"









@interface THTimeAnalysisViewController ()
{
     BOOL shouldUpdateView;
}
@property (strong, nonatomic)NSMutableArray* data;
@property (strong, nonatomic)NSMutableArray* color;
@property (strong, nonatomic)NSMutableArray* strings;
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
    [self.pieChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    [self.pieChart setLabelRadius:60];
    self.pieChart.showLabel = YES;
    [self.pieChart setPieRadius:120];
    [self.pieChart setShowPercentage:YES];
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChart setPieCenter:CGPointMake(125, 125)];
    [self.pieChart setUserInteractionEnabled:NO];
    [self.pieChart setLabelShadowColor:[UIColor blackColor]];
    
    NSLog(@"pie chart, %@", self.pieChart);
    
    _data = [[NSMutableArray alloc] init];
    _color = [[NSMutableArray alloc] init];
    _strings = [[NSMutableArray alloc] init];
    
    [self initilizeData];
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
    NSUInteger c =  [_data count];
    NSLog(@"number of Slices: %lu",(unsigned long)c);
    return c;
}

-(CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    CGFloat f = ((NSNumber*)[_data objectAtIndex:index]).floatValue;
    NSLog(@"f: %f", f);
    return f;
}

-(UIColor*)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [_color objectAtIndex:index];
}

-(NSString*)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    NSLog(@"text for slice: %@", [_strings objectAtIndex:index]);
    return [_strings objectAtIndex:index];
}

#pragma  mark - core date notification handler
-(void)dataStoreChanged:(id)sender
{
    shouldUpdateView = true;
}
@end
