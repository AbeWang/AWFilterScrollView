//
//  AWFilterViewController.h
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//
#import "AWFilterScrollView.h"

@interface AWFilterViewController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
AWFilterScrollViewDataSource,
AWFilterScrollViewDelegate>
{
    AWFilterScrollView *scrollView;
	UIImageView *previewView;
	UIActivityIndicatorView *indicatorView;
}

@property (retain, nonatomic) AWFilterScrollView *scrollView;
@property (retain, nonatomic) UIImageView *previewView;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@end
