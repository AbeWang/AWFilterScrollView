//
//  AWFilterViewController.m
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWFilterViewController.h"
#import "AWFilterButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation AWFilterViewController

- (void)dealloc
{
	[scrollView release]; scrollView = nil;
	[previewView release]; previewView = nil;
	[indicatorView release]; indicatorView = nil;
	[super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.scrollView = nil;
	self.previewView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Filter", nil);
}

- (void)loadView
{
	[super loadView];

	self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
	self.navigationController.toolbar.tintColor = [UIColor darkGrayColor];
    
	UIBarButtonItem *selectItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Photo", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAction)] autorelease];
	self.navigationItem.rightBarButtonItem = selectItem;
    
	UIBarButtonItem *spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIBarButtonItem *shareItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(([[UIDevice currentDevice].systemVersion doubleValue] >= 6.0) ? @"Share" : @"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(shareAction)] autorelease];

	self.navigationController.toolbarHidden = NO;
	self.toolbarItems = [NSArray arrayWithObjects:spaceItem, shareItem, nil];
    
	previewView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 220.0)];
	previewView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:previewView];

	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicatorView.frame = CGRectMake((self.view.bounds.size.width - 40.0) / 2, (self.view.bounds.size.height - 250.0) / 2, 40.0, 40.0);
	indicatorView.hidesWhenStopped = YES;
	[indicatorView stopAnimating];
	[self.view addSubview:indicatorView];
    
	scrollView = [[AWFilterScrollView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(previewView.frame) + 10.0, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(previewView.frame) - 98.0)];
	scrollView.filterDelegate = self;
	[self.view addSubview:scrollView];
}

- (BOOL)shouldAutorotate
{
	return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Actions

- (void)selectAction
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Camera Roll", nil), nil];
		[sheet showFromToolbar:self.navigationController.toolbar];
		[sheet release];
	}
	else {
		UIImagePickerController *controller = [[UIImagePickerController alloc] init];
		controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		controller.allowsEditing = NO;
		controller.delegate = self;
		[self presentModalViewController:controller animated:YES];
		[controller release];
	}
}

- (void)shareAction
{
    if (previewView.image) {
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 6.0) {
            NSString *textToShare = NSLocalizedString(@"[Abe Filter] Photo Sharing", nil);
            NSArray *activityItems = [NSArray arrayWithObjects:textToShare, previewView.image, nil];
            UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }
        else {
            UIImageWriteToSavedPhotosAlbum(previewView.image, nil, nil, nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex > 1) {
		return;
	}
    
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	switch (buttonIndex) {
		case 0:
			controller.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 1:
			controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
	}
	controller.delegate = self;
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

#pragma mark - UIImagePickerViewController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[previewView setImage:pickImage];
    [scrollView reloadItems];
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - AWFilterScrollView

- (NSInteger)numberOfItemsInFilterScrollView:(AWFilterScrollView *)inScrollView
{
    return 6;
}
- (UIImage *)originalImageInFilterScrollView:(AWFilterScrollView *)inScrollView
{
    return previewView.image;
}
- (AWFilterButtonItem *)filterScrollView:(AWFilterScrollView *)inScrollView itemAtIndex:(NSInteger)inIndex
{
    AWFilterButtonItem *item = nil;
    switch (inIndex) {
        case 0:
			item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeNormal] autorelease];
			item.name = NSLocalizedString(@"Normal", nil);
            break;
        case 1:
			item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeSepiaTone] autorelease];
			item.name = NSLocalizedString(@"Sepia Tone", nil);
            break;
        case 2:
			item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeToneCurve] autorelease];
			item.name = NSLocalizedString(@"Tone Curve", nil);
            break;
        case 3:
			item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeVibrance] autorelease];
			item.name = NSLocalizedString(@"Vibrance", nil);
            break;
        case 4:
			item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeVignette] autorelease];
			item.name = NSLocalizedString(@"Vignette", nil);
            break;
        case 5:
            item = [[[AWFilterButtonItem alloc] initWithType:AWFilterTypeHighlightShadow] autorelease];
            item.name = NSLocalizedString(@"Highlight Shadow", nil);
            break;
    }
    return item;
}
- (void)filterScrollView:(AWFilterScrollView *)inScrollView willSelectItem:(AWFilterButtonItem *)inItem
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[indicatorView startAnimating];
}
- (void)filterScrollView:(AWFilterScrollView *)inScrollView didSelectItem:(AWFilterButtonItem *)inItem outputImage:(UIImage *)inImage
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	[indicatorView stopAnimating];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.8;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.type = @"rippleEffect";
    
    [previewView.layer addAnimation:animation forKey:nil];
	[previewView setImage:inImage];
}

@synthesize scrollView;
@synthesize previewView;
@synthesize indicatorView;
@end
