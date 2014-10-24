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




+(CGFloat)getTotalTimeByCategory:(NSString*)category
{
    CGFloat second = 0;
    NSArray* array = [[THCoreDataManager sharedInstance] getEventModelsByType:THALLEVENT andCategory:category];
    for (EventModel* model in array) {
        NSSet* set = model.event;
        for(Event* event in set)
        {
            second+= event.duration.floatValue;
        }
    }
    return second;
    
    
}

+(NSDictionary*)getPercentagesByCategories:(NSArray*)categories
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    NSMutableArray* durationArray = [[NSMutableArray alloc] init];
    CGFloat sum = 0;
    for (NSString* c in categories) {
        CGFloat duration = [self getTotalTimeByCategory:c];
        sum+=duration;
        [durationArray addObject:[NSNumber numberWithFloat:duration]];
    }
    for (int i=0; i<[categories count]; i++) {
        NSString* category = [categories objectAtIndex:i];
        CGFloat percentage = ((NSNumber*)[durationArray objectAtIndex:i]).floatValue/sum;
        [dic setObject:[NSNumber numberWithFloat:percentage] forKey:category];
    }
    return dic;
}

+(NSDictionary*)getDurationByCategories:(NSArray*)categories
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    for (NSString* c in categories) {
        CGFloat duration = [self getTotalTimeByCategory:c];
        [dic setObject:[NSNumber numberWithFloat:duration] forKey:c];
    }
    return dic;
}

@end
