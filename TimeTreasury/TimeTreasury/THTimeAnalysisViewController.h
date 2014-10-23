//
//  THTimeAnalysisViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/19/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "XYPieChart.h"
#import "THCoreDataManager.h"
#import "THTimeAnalysisEngine.h"
#import "THColorPanel.h"
@interface THTimeAnalysisViewController : UIViewController<XYPieChartDataSource, XYPieChartDelegate>

@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;




@end
