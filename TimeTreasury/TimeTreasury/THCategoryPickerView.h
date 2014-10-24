//
//  THCategoryPickerView.h
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define categoryPickerViewHidenY 568.0
#define categoryPickerViewShownY 338.0
@protocol THCategoryPickerViewDelegate <NSObject>

-(void)catetoryPickerView:(UIView*)view finishPicking:(NSAttributedString*)string withCategory:(NSInteger)category;
-(void)catetoryPickerView:(UIView*)view valueChanged:(NSAttributedString*)string withCategory:(NSInteger)category;

@end

@interface THCategoryPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property(strong, nonatomic) UIButton* leftButton;
@property(strong, nonatomic) UIButton* rightButton;
@property(strong, nonatomic) UIPickerView* picker;


@property (assign) id<THCategoryPickerViewDelegate> delegate;
-(void)toTop:(id)sender;
-(id)initWithAllOption:(BOOL)with;
@end
