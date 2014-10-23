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
#import "THColorPanel.h"
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
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        _catDic = (NSDictionary*)[defaults objectForKey:@"Category"];
        _categories = [_catDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* s1, NSString* s2)
                       {
                           NSNumber* i1 = [_catDic objectForKey:s1];
                           NSNumber* i2 = [_catDic objectForKey:s2];
                           if (i1.integerValue<i2.integerValue) {
                               return -1;
                           }
                           if (i1.integerValue==i2.integerValue) {
                               return 0;
                           }
                           return 1;
                           
                       }];
        NSLog(@"categories: %@", _categories);
        //colors
        _colors = [defaults objectForKey:@"Colors"];
        
        //get attributed string array
        _atrStrings = [[NSMutableArray alloc] init];
        for (int row=0; row<[_categories count]; row++) {
            NSString* string = [_categories objectAtIndex:row];
            NSNumber* colorIndex = (NSNumber*)[_catDic objectForKey:string];
            UIColor* color = [THColorPanel getColor:[_colors objectAtIndex:colorIndex.intValue]];
            UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
            NSDictionary* atrDic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
            NSAttributedString* atrstr = [[NSAttributedString alloc] initWithString:[_categories objectAtIndex:row] attributes:atrDic];
            [_atrStrings addObject:atrstr];
        
        }
        
        
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
        UIColor* color = [UIColor blackColor];
        UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
        NSAttributedString* astr = [[NSAttributedString alloc] initWithString:@"All"
                                                                   attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font}];
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
    NSAttributedString* selected = [_atrStrings objectAtIndex:row];
    _category = selected;
    [self.delegate CatetoryPickerView:self  valueChanged:selected];
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
        [self.delegate CatetoryPickerView:self valueChanged:_category];
    }
}
@end
