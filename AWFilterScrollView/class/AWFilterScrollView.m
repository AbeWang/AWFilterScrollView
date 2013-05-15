//
//  AWFilterScrollView.m
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWFilterScrollView.h"
#import "AWFilterButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation AWFilterScrollView

- (void)dealloc
{
    filterDelegate = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
	self.pagingEnabled = NO;
	self.scrollEnabled = YES;
	self.bounces = YES;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
}

- (void)reloadItems
{
    for (AWFilterButtonItem *item in [self subviews]) {
        [item removeFromSuperview];
    }
    
    NSUInteger offset = 10.0;
    NSInteger itemCount = [filterDelegate numberOfItemsInFilterScrollView:self];
    for (NSInteger i = 0; i < itemCount; i++) {
        AWFilterButtonItem *item = [filterDelegate filterScrollView:self itemAtIndex:i];
        item.frame = CGRectMake(offset * (i + 1) + 90 * i, offset, 90.0, (self.bounds.size.height - 20.0));
        [item addTarget:self action:@selector(pressItem:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
		item.originalImage = [filterDelegate originalImageInFilterScrollView:self];
        [self addSubview:item];
    }

    AWFilterButtonItem *lastItem = (AWFilterButtonItem *)[self.subviews lastObject];
    [self setContentSize:CGSizeMake(CGRectGetMaxX(lastItem.frame) + offset, self.bounds.size.height)];
}

- (void)pressItem:(id)sender
{
    AWFilterButtonItem *selectedItem = (AWFilterButtonItem *)sender;
	[selectedItem outputImageWithDelegate:self];
}

#pragma mark - AWFilterButtonItem Delegate

- (void)filterButtonItemImageOutputWillBegin:(AWFilterButtonItem *)inItem
{
	[filterDelegate filterScrollView:self willSelectItem:inItem];
}
- (void)filterButtonItem:(AWFilterButtonItem *)inItem imageOutputDidEndWithImage:(UIImage *)inImage
{
	[filterDelegate filterScrollView:self didSelectItem:inItem outputImage:inImage];
}

@synthesize filterDelegate;
@end
