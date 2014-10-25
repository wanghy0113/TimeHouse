//
//  THCategoryLabelView.m
//  TimeTreasury
//
//  Created by WangHenry on 10/23/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCategoryLabelView.h"
#import "SketchProducer.h"
#import "THCategoryProcessor.h"
@implementation THCategoryLabelView

-(id)initWithCategory:(NSInteger)category andType:(THCategoryLabelType)type
{
    self = [super init];
    if (self) {
        UIFont* font = [UIFont fontWithName: @"Noteworthy-Bold" size: 16];
        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentNatural;
        NSDictionary* textFontAttributes = @{NSFontAttributeName:font , NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};
        NSAttributedString* atrStr = [[NSAttributedString alloc] initWithString:[THCategoryProcessor categoryString:category onlyActive:YES] attributes:textFontAttributes];
        CGRect rect = [atrStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, categoryLabelHeight)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           context:nil];
        
        
        self.bounds = CGRectMake(0, 0, rect.size.width+2*triangleWid+5, categoryLabelHeight);
        CALayer* maskLayer = [SketchProducer getMaskLayer:self.bounds];
        self.layer.mask = maskLayer;
        
        UIColor* color = [THCategoryProcessor categoryColor:category onlyActive:YES];
        self.backgroundColor = color;
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(triangleWid, -5, rect.size.width+5, rect.size.height)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font =font;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.text = [THCategoryProcessor categoryString:category onlyActive:YES];
        [self addSubview:_textLabel];
    
        
    }
    return self;
}



-(void)setType:(THCategoryLabelType)type
{
    
}

@end
