//
//  THTimeAnalysisEngine.m
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THTimeAnalysisEngine.h"
#import "THCoreDataManager.h"
@implementation THTimeAnalysisEngine




+(CGFloat)getTotalTimeByCategory:(NSInteger)category
{
    CGFloat second = 0;
    NSArray* array = [[THCoreDataManager sharedInstance] getEventModelsByType:THALLEVENT andCategory:category onlyActive:YES];
    for (EventModel* model in array) {
        NSSet* set = model.event;
        for(Event* event in set)
        {
            second+= event.duration.floatValue;
        }
    }
    return second;
    
    
}

+(NSArray*)getPercentagesByCategories:(NSArray*)categories
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    NSMutableArray* durationArray = [[NSMutableArray alloc] init];
    CGFloat sum = 0;
    for (NSNumber* i in categories) {
        CGFloat duration = [self getTotalTimeByCategory:i.integerValue];
        sum+=duration;
        [durationArray addObject:[NSNumber numberWithFloat:duration]];
    }
    for (int i=0; i<[durationArray count]; i++) {
        CGFloat percentage = ((NSNumber*)[durationArray objectAtIndex:i]).floatValue/sum;
        [res addObject:[NSNumber numberWithFloat:percentage]];
    }
    return res;
}

+(NSArray*)getDurationByCategories:(NSArray*)categories
{
    NSMutableArray* durationArray = [[NSMutableArray alloc] init];
    CGFloat sum = 0;
    for (NSNumber* i in categories) {
        CGFloat duration = [self getTotalTimeByCategory:i.integerValue];
        sum+=duration;
        [durationArray addObject:[NSNumber numberWithFloat:duration]];
    }
    return durationArray;
}

@end
