//
//  SketchProducer.m
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//


/***********
     book mark should be like this:
    (x,y)<------...........  -
               .         .   |
              .         .    h
               .         .   |
                ...........  -
 
                |---w---|
 
 ***********/

#import "SketchProducer.h"

static CGFloat triangleWid = 10;
@implementation SketchProducer

+(UIColor*)getColor:(NSDictionary *)dict
{
    NSNumber* red = (NSNumber*)[dict objectForKey:@"red"];
    NSNumber* green = (NSNumber*)[dict objectForKey:@"red"];
    NSNumber* blue = (NSNumber*)[dict objectForKey:@"red"];
    NSNumber* alpha = (NSNumber*)[dict objectForKey:@"red"];
    UIColor* color = [UIColor colorWithRed: red.floatValue green: green.floatValue blue: blue.floatValue alpha: alpha.floatValue];
    return color;

}

+(CAShapeLayer*)getFlashLayer:(CGRect)frame withColor:(UIColor *)c
{
    
    
    CGFloat x = 12;
    CGFloat y = 0;
    CGFloat rectWid = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    
    //// Shadow Declarations
    UIColor* shadow = UIColor.blackColor;
    CGSize shadowOffset = CGSizeMake(-1.5, 0);
    CGFloat shadowBlurRadius = 2;
    
    //add shape layer
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    shape.frame = frame;
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(x-triangleWid, y+rectHeight/2)];
    [bezierPath addLineToPoint: CGPointMake(x, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid+triangleWid, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid, y+rectHeight/2)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid+triangleWid, y)];
    [bezierPath addLineToPoint: CGPointMake(x, y)];
    [bezierPath addLineToPoint: CGPointMake(x-triangleWid, y+rectHeight/2)];
    [bezierPath closePath];
    
    UIColor* color = [UIColor colorWithRed: 0.61 green: 0.96 blue: 0.72 alpha: 1];
    shape.path = bezierPath.CGPath;
    shape.fillColor = color.CGColor;
    shape.fillRule = kCAFillRuleNonZero;
    
    //add shadow
    shape.shadowColor = shadow.CGColor;
    shape.shadowOffset = shadowOffset;
    shape.shadowRadius = shadowBlurRadius;
    shape.shadowOpacity = 1;
    
    //add flash
    CABasicAnimation* flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.duration = 1;
    flash.repeatCount = HUGE_VALF;
    flash.autoreverses = YES;
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.5];
    flash.removedOnCompletion = NO;
    [shape addAnimation:flash forKey:@"opacity"];
    
    return shape;
}


+(void)produceShortBookMarkWithFrame:(CGRect)frame withColor:(UIColor *)color withText:(NSString *)text
{
    
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat rectWid = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Shadow Declarations
    UIColor* shadow = UIColor.blackColor;
    CGSize shadowOffset = CGSizeMake(-1.5, 0);
    CGFloat shadowBlurRadius = 2;
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(x-triangleWid, y+rectHeight/2)];
    [bezierPath addLineToPoint: CGPointMake(x, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid+triangleWid, y+rectHeight)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid, y+rectHeight/2)];
    [bezierPath addLineToPoint: CGPointMake(x+rectWid+triangleWid, y)];
    [bezierPath addLineToPoint: CGPointMake(x, y)];
    [bezierPath addLineToPoint: CGPointMake(x-triangleWid, y+rectHeight/2)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [shadow CGColor]);
    [color setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(x, y-3, frame.size.width, 18);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Noteworthy-Bold" size: 10], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};
    
    [text drawInRect: textRect withAttributes: textFontAttributes];

}

+(void)produceDoneMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.890 green: 0.541 blue: 0.541 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Done"];
}

+(void)produceOnceMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.443 green: 0.671 blue: 0.922 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Once"];
}

+(void)produceDailyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.435 green: 0.843 blue: 0.835 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Daily"];
}

+(void)produceWeeklyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.761 green: 0.471 blue: 0.808 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Weekly"];
}

+(void)produceMonthlyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.87 green: 0.88 blue: 0.35 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Monthly"];
}

+(void)produceYearlyMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.435 green: 0.843 blue: 0.835 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"Yearly"];
}

+(void)produceRunningMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.61 green: 0.96 blue: 0.72 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@""];
}

+(void)produceFutureMark:(CGPoint)location
{
    UIColor* color = [UIColor colorWithRed: 0.690 green: 0.910 blue: 0.408 alpha: 1];
    [self produceShortBookMarkWithFrame:CGRectMake(location.x, location.y, 35, 12) withColor:color withText:@"To Do"];
}
@end
