//
//  THTimeAnalysisViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 10/19/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "THCoreDataManager.h"
#import "THTimeAnalysisEngine.h"
#import "THSettingFacade.h"
#import "THCategoryLabelView.h"
#import "THDatePickView.h"
@interface THTimeAnalysisViewController : UIViewController<XYPieChartDataSource, XYPieChartDelegate, THDatePickViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *unusedCategoryView;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) IBOutlet UIButton *changeStartTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *changeEndTimeButton;
@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *endTimeLabel;




@end
