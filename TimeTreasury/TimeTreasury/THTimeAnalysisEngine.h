//
//  THTimeAnalysisEngine.h
//  TimeTreasury
//
//  Created by WangHenry on 10/22/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "EventModel.h"
@interface THTimeAnalysisEngine : NSObject

+(NSDictionary*)getPercentagesByCategories:(NSArray*)categories;

+(NSDictionary*)getDurationByCategories:(NSArray*)categories;


@end
