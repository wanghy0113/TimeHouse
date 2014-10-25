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
#import "THCategoryProcessor.h"
@interface THCategoryPickerView()
@property (strong, nonatomic) NSMutableArray* categories;
@property (assign) NSInteger selectedRow;
@property (strong, nonatomic) NSDictionary* catDic;
@property (strong, nonatomic) NSMutableArray* colors;
@property (strong, nonatomic) NSMutableArray* atrStrings;
@property (assign) BOOL withAll;

@end

@implementation THCategoryPickerView


-(id)init
{
    self = [super init];
    if(self)
    {
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
        
        NSArray* catarray = [THCategoryProcessor getActiveCategories];
//        _categories = [_catDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* s1, NSString* s2)
//                       {
//                           NSNumber* i1 = [_catDic objectForKey:s1];
//                           NSNumber* i2 = [_catDic objectForKey:s2];
//                           if (i1.integerValue<i2.integerValue) {
//                               return -1;
//                           }
//                           if (i1.integerValue==i2.integerValue) {
//                               return 0;
//                           }
//                           return 1;
//                           
//                       }];
//        NSLog(@"categories: %@", _categories);
        //colors
//        _colors = [[NSMutableArray alloc] init];
        
        //get attributed string array
        _atrStrings = [[NSMutableArray alloc] init];
        _categories = [[NSMutableArray alloc] init];
        for (int row=0; row<[catarray count]; row++) {
            NSLog(@"row: %d", row);
            NSNumber* number = [catarray objectAtIndex:row];
            UIColor* color = [THCategoryProcessor categoryColor:number.integerValue onlyActive:YES];
            UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
            NSDictionary* atrDic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
            NSAttributedString* atrstr = [[NSAttributedString alloc] initWithString:[THCategoryProcessor categoryString:number.integerValue onlyActive:YES] attributes:atrDic ];
            [_atrStrings addObject:atrstr];
            [_categories addObject:[NSNumber numberWithInteger:row]];
        }
        
        _selectedRow = 0;
        _picker  = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 25, 320, 162)];
        _picker.dataSource = self;
        _picker.delegate = self;
        [self addSubview:_picker];
    }
    return self;
}

-(id)initWithAllOption:(BOOL)with
{
    
    self = [self init];
    if (self) {
        _withAll = true;
        UIColor* color = [UIColor blackColor];
        UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
        NSAttributedString* astr = [[NSAttributedString alloc] initWithString:@"All"
                                                                   attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font}];
        [_categories insertObject:[NSNumber numberWithInteger:-1] atIndex:0];
        [_atrStrings insertObject:astr atIndex:0];

    }
    return self;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_atrStrings count];
}

-(NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_atrStrings objectAtIndex:row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSAttributedString* string = [_atrStrings objectAtIndex:row];
    NSInteger index = ((NSNumber*)[_categories objectAtIndex:row]).integerValue;
    _selectedRow = row;
    [self.delegate catetoryPickerView:self  valueChanged:string withCategory:index];
}


-(void)finishPick:(id)sender
{
    NSAttributedString* string = [_atrStrings objectAtIndex:_selectedRow];
    NSInteger index = ((NSNumber*)[_categories objectAtIndex:_selectedRow]).integerValue;
    [self.delegate catetoryPickerView:self finishPicking:string withCategory:index];
}



-(void)toTop:(id)sender
{
    if ([_categories count]>0) {
        [_picker selectRow:0 inComponent:0 animated:YES];
        _selectedRow = 0;
        NSAttributedString* string = [_atrStrings objectAtIndex:_selectedRow];
        NSInteger index = ((NSNumber*)[_categories objectAtIndex:_selectedRow]).integerValue;
        [self.delegate catetoryPickerView:self finishPicking:string withCategory:index];
    }
}
@end
