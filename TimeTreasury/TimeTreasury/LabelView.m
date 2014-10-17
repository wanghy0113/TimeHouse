//
//  LabelView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/2/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "LabelView.h"
#import "SketchProducer.h"
static CGFloat rectHeight = 12;
static CGFloat rectWid = 53;
static CGFloat x = 0;
static CGFloat y = 0;
@interface LabelView()
{
    CAShapeLayer *_shape;
    UILabel* label;
    
}

@end


@implementation LabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor* shadow = UIColor.blackColor;
        CGSize shadowOffset = CGSizeMake(0.1, 2.4);
        CGFloat shadowBlurRadius = 4;
        
        //add shape layer
        _shape = [[CAShapeLayer alloc] init];
        _shape.frame = CGRectMake(0, 0, rectHeight+rectWid, rectHeight);
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(x+rectHeight, y+rectHeight)];
        [bezierPath addLineToPoint: CGPointMake(x+rectHeight+rectWid, y+rectHeight)];
        [bezierPath addLineToPoint: CGPointMake(x+rectHeight+rectWid, y)];
        [bezierPath addLineToPoint: CGPointMake(x+rectHeight, y)];
        [bezierPath addLineToPoint: CGPointMake(x, y+rectHeight/2)];
        [bezierPath addLineToPoint: CGPointMake(x+rectHeight, y+rectHeight)];
        [bezierPath closePath];
        
        UIColor* color = [UIColor colorWithRed: 0.61 green: 0.96 blue: 0.72 alpha: 1];
        _shape.path = bezierPath.CGPath;
        _shape.fillColor = color.CGColor;
        _shape.fillRule = kCAFillRuleNonZero;
        
        //add shadow
        _shape.shadowColor = shadow.CGColor;
        _shape.shadowOffset = shadowOffset;
        _shape.shadowRadius = shadowBlurRadius;
        _shape.shadowOpacity = 1;
        
        //add flash
        CABasicAnimation* flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
        flash.duration = 1;
        flash.repeatCount = HUGE_VALF;
        flash.autoreverses = YES;
        flash.fromValue = [NSNumber numberWithFloat:1.0];
        flash.toValue = [NSNumber numberWithFloat:0.3];
        flash.removedOnCompletion = NO;
        [_shape addAnimation:flash forKey:@"opacity"];
        
        [self.layer addSublayer:_shape];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(rectHeight-2, 0, rectWid+2, rectHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Noteworthy-Bold" size:10];
        [self addSubview:label];
        
    }
    return self;
}

-(void)displayText:(NSString*) text
{
    label.text = text;
}



@end
