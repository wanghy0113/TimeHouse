//
//  THManageScrollView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/4/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THManageScrollView.h"

@interface THManageScrollView()
{
    float totalHeight;
    int cellCount;
    
}
@end
@implementation THManageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        totalHeight = 0;
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        
    }
    return self;
}

-(void)addEventModelCell:(THEventModelCellView*)cell
{
    cellCount++;
    if (cellCount%2==1) {
        cell.frame = CGRectMake(0, totalHeight,
                                     cell.bounds.size.width, cell.bounds.size.height);
        totalHeight = totalHeight + cell.bounds.size.height;
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
    }
    else
    {
        cell.frame = CGRectMake(5+cell.bounds.size.width, totalHeight-cell.bounds.size.height,
                                     cell.bounds.size.width, cell.bounds.size.height);
    }
    [self addSubview:cell];
}




@end
