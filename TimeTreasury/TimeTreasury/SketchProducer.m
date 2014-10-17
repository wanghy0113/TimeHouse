//
//  SketchProducer.m
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "SketchProducer.h"

@implementation SketchProducer

+(void)produceShortBookMarkWithFrame:(CGRect)frame withColor:(UIColor *)color withText:(NSString *)text
{
    
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat rectWid = frame.size.width-frame.size.height;
    CGFloat rectHeight = frame.size.height;
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Shadow Declarations
    UIColor* shadow = UIColor.blackColor;
    CGSize shadowOffset = CGSizeMake(0.1, 2.1);
    CGFloat shadowBlurRadius = 4;
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(x+rectHeight, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectHeight+rectWid, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectHeight+rectWid, y)];
    [bezierPath addLineToPoint: CGPointMake(x+rectHeight, y)];
    [bezierPath addLineToPoint: CGPointMake(x, y+rectHeight/2)];
    [bezierPath addLineToPoint: CGPointMake(x+rectHeight, y+rectHeight)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [shadow CGColor]);
    [color setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(x+5, y-3, frame.size.width, 18);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Noteworthy-Bold" size: 10], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};
    
    [text drawInRect: textRect withAttributes: textFontAttributes];

}

+(void)produceDoneMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 1.0 green: 0.45 blue: 0.45 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Done"];
}

+(void)produceOnceMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.55 green: 0.76 blue: 1.0 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Once"];
}

+(void)produceDailyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.435 green: 0.843 blue: 0.835 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Daily"];
}

+(void)produceWeeklyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.97 green: 0.8 blue: 0.52 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Weekly"];
}

+(void)produceMonthlyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.435 green: 0.843 blue: 0.835 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Monthly"];
}

+(void)produceYearlyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.435 green: 0.843 blue: 0.835 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"Yearly"];
}

+(void)produceRunningMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.61 green: 0.96 blue: 0.72 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 60, 12) withColor:color withText:@""];
}

+(void)produceFutureMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.28 green: 0.81 blue: 0.32 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 50, 12) withColor:color withText:@"To Do"];
}
@end
