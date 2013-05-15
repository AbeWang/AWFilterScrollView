//
//  AWFilterScrollView.h
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWFilterButtonItem.h"

@class AWFilterScrollView;

@protocol AWFilterScrollViewDataSource <NSObject>
- (NSInteger)numberOfItemsInFilterScrollView:(AWFilterScrollView *)inScrollView;
- (UIImage *)originalImageInFilterScrollView:(AWFilterScrollView *)inScrollView;
- (AWFilterButtonItem *)filterScrollView:(AWFilterScrollView *)inScrollView itemAtIndex:(NSInteger)inIndex;
@end

@protocol AWFilterScrollViewDelegate <NSObject>
- (void)filterScrollView:(AWFilterScrollView *)inScrollView willSelectItem:(AWFilterButtonItem *)inItem;
- (void)filterScrollView:(AWFilterScrollView *)inScrollView didSelectItem:(AWFilterButtonItem *)inItem outputImage:(UIImage *)inImage;
@end

@interface AWFilterScrollView : UIScrollView
<UIScrollViewDelegate,
AWFilterButtonItemDelegate>
{
    id<AWFilterScrollViewDataSource, AWFilterScrollViewDelegate> filterDelegate;
}

- (void)reloadItems;

@property (assign, nonatomic) id<AWFilterScrollViewDataSource, AWFilterScrollViewDelegate> filterDelegate;
@end
