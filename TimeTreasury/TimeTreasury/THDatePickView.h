//
//  THDatePickView.h
//  TimeTreasury
//
//  Created by WangHenry on 10/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THDatePickViewDelegate <NSObject>

-(void)finishPickingDate:(NSDate*)date;
-(void)dateValueChanged:(NSDate*)date;

@end

@interface THDatePickView : UIView
@property(strong, nonatomic) UIButton* leftButton;
@property(strong, nonatomic) UIButton* rightButton;
@property(strong, nonatomic) UIDatePicker* datePicker;


@property (assign) id<THDatePickViewDelegate> delegate;

-(void)setDatePickMode:(UIDatePickerMode)mode;
-(NSDate*)getDate;


@end
