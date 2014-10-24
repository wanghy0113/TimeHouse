//
//  THEventManagementViewController.h
//  TimeTreasury
//
//  Created by WangHenry on 6/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEventModelCellView.h"
#import "THCoreDataManager.h"
#import "THFileManager.h"
#import "THCategoryPickerView.h"

@interface THEventManagementViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, THCategoryPickerViewDelegate, THEventModelCellDelegate, UIAlertViewDelegate>


@end