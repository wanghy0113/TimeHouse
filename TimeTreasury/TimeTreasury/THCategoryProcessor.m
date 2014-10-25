//
//  THCategoryProcessor.m
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCategoryProcessor.h"

@implementation THCategoryProcessor


+(UIColor*)getColor:(NSDictionary *)dict
{
    NSNumber* red = (NSNumber*)[dict objectForKey:@"red"];
    NSNumber* green = (NSNumber*)[dict objectForKey:@"green"];
    NSNumber* blue = (NSNumber*)[dict objectForKey:@"blue"];
    NSNumber* alpha = (NSNumber*)[dict objectForKey:@"alpha"];
    UIColor* color = [UIColor colorWithRed: red.floatValue green: green.floatValue blue: blue.floatValue alpha: alpha.floatValue];
    return color;
    
}

+(UIColor*)categoryColor:(NSInteger)categoryIndex onlyActive:(BOOL)only
{
    if (only&&![self categoryIsActive:categoryIndex]) {
        categoryIndex = 0;
    }
    NSDictionary* dic = [self categoryDictionary:categoryIndex];
    return [self getColor:dic];
}

+(NSDictionary*)categoryDictionary:(NSInteger)categoryIndex
{
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
    return [array objectAtIndex:categoryIndex];
}

+(NSString*)categoryString:(NSInteger)categoryIndex onlyActive:(BOOL)only
{
    if (only&&![self categoryIsActive:categoryIndex]) {
        categoryIndex = 0;
    }
    NSDictionary* dic = [self categoryDictionary:categoryIndex];
    return [dic objectForKey:@"category"];
}

+(BOOL)categoryIsActive:(NSInteger)categoryIndex
{
    NSDictionary* dic = [self categoryDictionary:categoryIndex];
    return ((NSNumber*)[dic objectForKey:@"active"]).boolValue;
}

+(NSArray*)getActiveCategories
{
    NSArray* dics = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i=0; i<[dics count]; i++) {
        NSLog(@"i: %d", i);
        NSDictionary* dic = [dics objectAtIndex:i];
        NSNumber* bNumber = (NSNumber*)[dic objectForKey:@"active"];
        if (bNumber.boolValue) {
            NSLog(@"active i: %d", i);
            [result addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return result;
}

+(NSArray*)getInactiveCategories
{
    NSArray* dics = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i=0; i<[dics count]; i++) {
        NSDictionary* dic = [dics objectAtIndex:i];
        NSNumber* bNumber = (NSNumber*)[dic objectForKey:@"active"];
        if (!bNumber.boolValue) {
            [result addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return result;
}

+(NSArray*)getAllCategories
{
    NSArray* dics = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i=0; i<[dics count]; i++) {
        [result addObject:[NSNumber numberWithInteger:i]];
    }
    return result;
}

+(void)setCategoryColor:(NSInteger)categoryIndex withColor:(UIColor*)color
{
    CGFloat red, blue, green, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSMutableDictionary* dic = [[self categoryDictionary:categoryIndex] mutableCopy];
    [dic setObject:[NSNumber numberWithFloat:red] forKey:@"red"];
    [dic setObject:[NSNumber numberWithFloat:green] forKey:@"green"];
    [dic setObject:[NSNumber numberWithFloat:blue] forKey:@"blue"];
    [dic setObject:[NSNumber numberWithFloat:alpha] forKey:@"alpha"];
    NSMutableArray* array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Category"] mutableCopy];
    [array replaceObjectAtIndex:categoryIndex withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Category"];
    
}

+(void)setCategoryString:(NSInteger)categoryIndex withString:(NSString*)string
{
    NSMutableDictionary* dic = [[self categoryDictionary:categoryIndex] mutableCopy];
    [dic setObject:string forKey:@"category"];
    NSMutableArray* array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Category"] mutableCopy];
    [array replaceObjectAtIndex:categoryIndex withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Category"];
}

+(void)setCategoryActive:(NSInteger)categoryIndex withActive:(BOOL)active
{
    NSMutableDictionary* dic = [[self categoryDictionary:categoryIndex] mutableCopy];
    [dic setObject:[NSNumber numberWithBool:active] forKey:@"active"];
    NSMutableArray* array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Category"] mutableCopy];
    [array replaceObjectAtIndex:categoryIndex withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Category"];
}
@end
