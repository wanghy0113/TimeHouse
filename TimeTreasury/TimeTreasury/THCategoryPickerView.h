//
//  THCategoryPickerView.h
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THCategoryPickerViewDelegate <NSObject>

-(void)CatetoryPickerView:(UIView*)view finishPicking:(NSAttributedString*)catogery;
-(void)CatetoryPickerView:(UIView*)view valueChanged:(NSAttributedString*)catogery;

@end

@interface THCategoryPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property(strong, nonatomic) UIButton* leftButton;
@property(strong, nonatomic) UIButton* rightButton;
@property(strong, nonatomic) UIPickerView* picker;


@property (assign) id<THCategoryPickerViewDelegate> delegate;
-(void)toTop:(id)sender;

@end
