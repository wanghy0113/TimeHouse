//
//  SketchProducer.h
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGFloat triangleWid = 10.0;
static const CGFloat dataTypeLabelWid = 50.0;
static const CGFloat labelHei = 15.0;
static const CGFloat textSize = 12.0;
static const CGFloat colorAlpha = 1;
@interface SketchProducer : NSObject



+(void)drawLabel:(CGRect)frame withColor:(UIColor *)color withText:(NSString *)text;

+(void)produceDailyMark:(CGPoint)location;

+(void)produceDoneMark:(CGPoint)location;

+(void)produceRunningMark:(CGPoint)location;

+(void)produceWeeklyMark:(CGPoint)location;

+(void)produceMonthlyMark:(CGPoint)location;

+(void)produceFutureMark:(CGPoint)location;

+(void)produceOnceMark:(CGPoint)location;

+(CAShapeLayer*)getFlashLayer:(CGRect)frame withColor:(UIColor *)c;


@end
