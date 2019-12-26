//
//  DSBarChart.h
//  DSBarChart
//
//  Created by DhilipSiva Bijju on 31/10/12.
//  Copyright (c) 2012 Tataatsu IdeaLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChartViewDelegate <NSObject>
@optional
- (void)chartViewTapped:(NSInteger)tag;
@end

@interface DSBarChart : UIView
-(DSBarChart * )initWithFrame:(CGRect)frame
                        color:(UIColor*)theColor
                   references:(NSArray *)references
                    andValues:(NSArray *)values;
@property (atomic) int numberOfBars;
@property (atomic) float maxLen;
@property (atomic, strong) UIColor *color;
@property (atomic) NSArray* vals;
@property (atomic) NSArray* refs;

@property (nonatomic, weak) id <ChartViewDelegate> delegate;

@end
