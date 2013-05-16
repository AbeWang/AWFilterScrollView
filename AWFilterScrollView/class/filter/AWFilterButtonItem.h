//
//  AWFilterButtonItem.h
//  AWFilterScrollView
//
//  Created by Abe on 13/5/15.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@class AWFilterButtonItem;

@protocol AWFilterButtonItemDelegate <NSObject>
- (void)filterButtonItemImageOutputWillBegin:(AWFilterButtonItem *)inItem;
- (void)filterButtonItem:(AWFilterButtonItem *)inItem imageOutputDidEndWithImage:(UIImage *)inImage;
@end

typedef enum {
    AWFilterTypeNormal = 0,
    AWFilterTypeSepiaTone,
    AWFilterTypeToneCurve,
    AWFilterTypeVibrance,
    AWFilterTypeVignette,
    AWFilterTypeHighlightShadow
} AWFilterType;

@interface AWFilterButtonItem : UIControl
{
    AWFilterType type;
	UIImage *originalImage;
	NSString *name;
}

- (id)initWithType:(AWFilterType)inType;

- (void)outputImageWithDelegate:(id<AWFilterButtonItemDelegate>)inDelegate;

@property (assign, nonatomic) AWFilterType type;
@property (retain, nonatomic) UIImage *originalImage;
@property (retain, nonatomic) NSString *name;
@end
