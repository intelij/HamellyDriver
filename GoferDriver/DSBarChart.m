//
//  DSBarChart.m
//  DSBarChart
//
//  Created by DhilipSiva Bijju on 31/10/12.
//  Copyright (c) 2012 Tataatsu IdeaLabs. All rights reserved.
//

#import "DSBarChart.h"

@implementation DSBarChart
@synthesize color, numberOfBars, maxLen, refs, vals;

-(DSBarChart *)initWithFrame:(CGRect)frame
                       color:(UIColor *)theColor
                  references:(NSArray *)references
                   andValues:(NSArray *)values
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = theColor;
        self.vals = values;
        self.refs = references;
        self.backgroundColor = [UIColor redColor];

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)calculate{
    self.numberOfBars = [self.vals count];
    for (NSNumber *val in vals) {
        float iLen = [val floatValue];
        if (iLen > self.maxLen) {
            self.maxLen = iLen;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    /// Drawing code
    [self calculate];
    self.numberOfBars = 7;
    float rectWidth = (float)(rect.size.width-(self.numberOfBars)) / (float)self.numberOfBars;
    CGContextRef context = UIGraphicsGetCurrentContext();
    float LBL_HEIGHT = 20.0f, iLen, x, heightRatio, height, y;
    UIColor *iColor = [UIColor colorWithRed: 47.0 / 255.0 green: 168.0 / 255.0 blue: 32.0 / 255.0 alpha:1.0];
    
    /// Draw Bars
    for (int barCount = 0; barCount < self.numberOfBars; barCount++) {
        
        /// Calculate dimensions
        iLen = [[vals objectAtIndex:barCount] floatValue];
        x = barCount * (rectWidth);
        heightRatio = (self.maxLen == 0) ? 0 : iLen / self.maxLen;
        height = heightRatio * rect.size.height;
        if (height < 0.1f)
            height = 0.0f;
        y = rect.size.height - height - LBL_HEIGHT;
        
        /// Reference Label.
        UILabel *lblRef = [[UILabel alloc] initWithFrame:CGRectMake(barCount + x, rect.size.height - LBL_HEIGHT, rectWidth-10, LBL_HEIGHT)];
        lblRef.text = [refs objectAtIndex:barCount];
        lblRef.font = [UIFont fontWithName:@"ClanPro-Book" size:13];

        lblRef.adjustsFontSizeToFitWidth = TRUE;
        lblRef.adjustsLetterSpacingToFitWidth = TRUE;
        lblRef.textColor = self.color;
        [lblRef setTextAlignment:NSTextAlignmentCenter];
        lblRef.backgroundColor = [UIColor clearColor];
        [self addSubview:lblRef];
        
        /// Set color and draw the bar
//        iColor = [UIColor colorWithRed: 47.0 / 255.0 green: 168.0 / 255.0 blue: 32.0 / 255.0 alpha:1.0];
        UIButton *lblRefe = [UIButton buttonWithType:UIButtonTypeCustom];
//        @try {
            lblRefe.frame = CGRectMake(barCount + x, y, rectWidth-10, height);
//        } @catch (NSException *exception) {
//            
//        } @finally {
//            lblRefe.frame = CGRectMake(barCount + x,0, rectWidth-10, 0);
//        }
        lblRefe.tag = barCount;
//        [UIView animateWithDuration:1.25 animations:^{
//            CGContextSetFillColorWithColor(context, iColor.CGColor);
//        CGRect barRect = CGRectMake(barCount + x, y, rectWidth-10, height);
//            CGContextFillRect(context, barRect);
//        lblRefe.frame = barRect;

            [lblRefe addTarget:self action:@selector(onChartTapped:) forControlEvents:UIControlEventTouchUpInside];
            lblRefe.backgroundColor = iColor;
            [self addSubview:lblRefe];
//        }];
    }
}

-(void)onChartTapped:(UIButton *)sender
{
    [self.delegate chartViewTapped:sender.tag];
}

    /// pivot
//    CGRect frame = CGRectZero;
//    frame.origin.x = rect.origin.x;
//    frame.origin.y = rect.origin.y - LBL_HEIGHT;
//    frame.size.height = LBL_HEIGHT;
//    frame.size.width = rect.size.width;
//    UILabel *pivotLabel = [[UILabel alloc] initWithFrame:frame];
//    pivotLabel.text = [NSString stringWithFormat:@"%d", (int)self.maxLen];
//    pivotLabel.backgroundColor = [UIColor clearColor];
//    pivotLabel.textColor = self.color;
//    [self addSubview:pivotLabel];
//    
//    /// A line
//    frame = rect;
//    frame.size.height = 1.0;
//    CGContextSetFillColorWithColor(context, self.color.CGColor);
//    CGContextFillRect(context, frame);


@end
