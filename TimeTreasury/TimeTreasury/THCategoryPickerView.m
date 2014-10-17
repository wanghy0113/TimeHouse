//
//  THCategoryPickerView.m
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCategoryPickerView.h"
#import "THJSONMan.h"
#import "SketchProducer.h"
@interface THCategoryPickerView()
@property (strong, nonatomic) NSArray* categories;
@property (strong, nonatomic) NSAttributedString* category;
@property (strong, nonatomic) NSDictionary* catDic;
@property (strong, nonatomic) NSArray* colors;
@property (strong, nonatomic) NSMutableArray* atrStrings;

@end

@implementation THCategoryPickerView


-(id)init
{
    self = [super init];
    if(self)
    {
        NSLog(@"Date picker view init!");
        self.backgroundColor = [UIColor whiteColor];
    
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(43, 0, 46, 25)];
        [_leftButton setImage:[UIImage imageNamed:@"TextTop"] forState:UIControlStateNormal];
        _leftButton.imageEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 6);
        [_leftButton addTarget:self action:@selector(toTop:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(227, 0, 46, 25)];
        [_rightButton setImage:[UIImage imageNamed:@"TextDone"] forState:UIControlStateNormal];
        _rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 6);
        [_rightButton addTarget:self action:@selector(finishPick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _atrStrings = [[NSMutableArray alloc] init];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        _catDic = (NSDictionary*)[defaults objectForKey:@"Category"];
        _categories = _catDic.allKeys;
        NSLog(@"categories: %@", _categories);
        //colors
        _colors = [defaults objectForKey:@"Colors"];
        
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

-(NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString* string = [_categories objectAtIndex:row];
    NSNumber* colorIndex = (NSNumber*)[_catDic objectForKey:string];
    NSLog(@"color index: %@", colorIndex);
    UIColor* color = [SketchProducer getColor:[_colors objectAtIndex:colorIndex.intValue]];
    UIFont* font = [UIFont fontWithName:@"NoteWorthy" size:15];
    NSLog(@"font: %@", font);
    NSDictionary* atrDic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    NSAttributedString* atrstr = [[NSAttributedString alloc] initWithString:[_categories objectAtIndex:row] attributes:atrDic];
    [_atrStrings addObject:atrstr];
    return atrstr;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    NSLog(@"did select");
//    NSAttributedString* selected = [_atrStrings objectAtIndex:row];
//    _category = selected;
//    [self.delegate CatetoryPickerView:self  valueChanged:selected];
}


-(void)finishPick:(id)sender
{
    [self.delegate CatetoryPickerView:self  finishPicking:_category];
}



-(void)toTop:(id)sender
{
    if ([_categories count]>0) {
        [_picker selectRow:0 inComponent:0 animated:YES];
        _category = [_atrStrings objectAtIndex:0];
        [self.delegate CatetoryPickerView:self valueChanged:[_categories objectAtIndex:0]];
    }
}
@end
