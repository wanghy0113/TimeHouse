//
//  THColorPanel.m
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THColorPanel.h"


@implementation THColorPanel

+(UIColor*)getColor:(NSDictionary *)dict
{
    NSNumber* red = (NSNumber*)[dict objectForKey:@"red"];
    NSNumber* green = (NSNumber*)[dict objectForKey:@"green"];
    NSNumber* blue = (NSNumber*)[dict objectForKey:@"blue"];
    NSNumber* alpha = (NSNumber*)[dict objectForKey:@"alpha"];
    UIColor* color = [UIColor colorWithRed: red.floatValue green: green.floatValue blue: blue.floatValue alpha: alpha.floatValue];
    return color;
    
}

+(UIColor*)getColorFromCategory:(NSString*)category
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* catDic = (NSDictionary*)[defaults objectForKey:@"Category"];
    
    //colors
    NSArray* colors = [defaults objectForKey:@"Colors"];
    NSNumber* colorIndex = [catDic objectForKey:category];
    return [self getColor:[colors objectAtIndex:colorIndex.intValue]];
    
}

@end

