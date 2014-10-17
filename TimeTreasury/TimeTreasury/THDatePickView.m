//
//  THDatePickView.m
//  TimeTreasury
//
//  Created by WangHenry on 10/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THDatePickView.h"

@implementation THDatePickView

-(id)init
{
    self = [super init];
    if(self)
    {
        NSLog(@"Date picker view init!");
        self.backgroundColor = [UIColor whiteColor];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(43, 0, 46, 25)];
        [_leftButton setImage:[UIImage imageNamed:@"TextNow"] forState:UIControlStateNormal];
        _leftButton.imageEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 6);
        
        //_leftButton.backgroundColor = [UIColor blueColor];
        [_leftButton addTarget:self action:@selector(dateToNow:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(227, 0, 46, 25)];
        [_rightButton setImage:[UIImage imageNamed:@"TextDone"] forState:UIControlStateNormal];
        _rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 6);
        [_rightButton addTarget:self action:@selector(finishPick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 25, 320, 162)];
        _datePicker.date = [NSDate date];
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_datePicker];
    }
    return self;
}


-(void)setDatePickMode:(UIDatePickerMode)mode
{
    _datePicker.datePickerMode = mode;
}

-(void)dateToNow:(id)sender
{
    [_datePicker setDate:[NSDate date]];
}

-(void)finishPick:(id)sender
{
    [self.delegate finishPickingDate:_datePicker.date];
}

-(void)dateChanged:(id)sender
{
    [self.delegate dateValueChanged:_datePicker.date];
}

-(NSDate*)getDate
{
    return _datePicker.date;
}
@end
