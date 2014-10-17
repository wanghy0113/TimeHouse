//
//  THCategoryPickerView.m
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCategoryPickerView.h"
#import "THJSONMan.h"

@interface THCategoryPickerView()
@property (strong, nonatomic) NSArray* categories;
@property (strong, nonatomic)NSString* category;

@end

@implementation THCategoryPickerView


-(id)init
{
    self = [super init];
    if(self)
    {
        NSLog(@"Date picker view init!");
        self.backgroundColor = [UIColor whiteColor];
    
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(227, 0, 46, 25)];
        [_rightButton setImage:[UIImage imageNamed:@"TextDone"] forState:UIControlStateNormal];
        _rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 6);
        [_rightButton addTarget:self action:@selector(finishPick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _category = @"";
        NSURL* jsonURL =  [[NSBundle mainBundle] URLForResource:@"Category" withExtension:@"json"];
        _categories = [THJSONMan getKeys:[NSData dataWithContentsOfURL:jsonURL]];
  
        NSLog(@"d: %@", [NSData dataWithContentsOfURL:jsonURL]);
        NSLog(@"c: %@",_categories);
        
        
        _picker  = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 25, 320, 162)];
        _picker.dataSource = self;
        _picker.delegate = self;
        [self addSubview:_picker];
    }
    return self;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_categories count];
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_categories objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString* selected = [_categories objectAtIndex:row];
    _category = selected;
    [self.delegate CatetoryPickerView:self  valueChanged:selected];
}

-(void)finishPick:(id)sender
{
    [self.delegate CatetoryPickerView:self  finishPicking:_category];
}

@end
