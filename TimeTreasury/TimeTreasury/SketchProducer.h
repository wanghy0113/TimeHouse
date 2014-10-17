//
//  SketchProducer.h
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SketchProducer : NSObject

+(void)produceShortBookMarkWithFrame:(CGRect)frame withColor:(UIColor*)color withText:(NSString*)text;

+(void)produceDailyMark:(CGPoint)location;

+(void)produceDoneMark:(CGPoint)location;

+(void)produceRunningMark:(CGPoint)location;

+(void)produceWeeklyMark:(CGPoint)location;

+(void)produceMonthlyMark:(CGPoint)location;

+(void)produceFutureMark:(CGPoint)location;

+(void)produceOnceMark:(CGPoint)location;

@end
