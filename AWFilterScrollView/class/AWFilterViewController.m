//
//  AWFilterViewController.m
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWFilterViewController.h"
#import "AWFilterButtonItem.h"

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

	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
	self.navigationController.toolbar.tintColor = [UIColor darkGrayColor];
    
	UIBarButtonItem *selectItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Photo", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAction)] autorelease];
	self.navigationItem.rightBarButtonItem = selectItem;
    
	UIBarButtonItem *spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *saveItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction)] autorelease];
	self.navigationController.toolbarHidden = NO;
	self.toolbarItems = [NSArray arrayWithObjects:spaceItem, saveItem, nil];
    
	previewView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 200.0)];
	previewView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:previewView];

	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicatorView.frame = CGRectMake((self.view.bounds.size.width - 40.0) / 2, (self.view.bounds.size.height - 240.0) / 2, 40.0, 40.0);
	indicatorView.hidesWhenStopped = YES;
	[indicatorView stopAnimating];
	[previewView addSubview:indicatorView];
    
	scrollView = [[AWFilterScrollView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(previewView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(previewView.frame) - 88.0)];
	scrollView.filterDelegate = self;
	[self.view addSubview:scrollView];
}

- (BOOL)shouldAutorotate
{
	return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return NO;
}

#pragma mark -
#pragma mark Actions

- (void)selectAction
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Camera Roll", nil), nil];
		[sheet showInView:self.view];
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

- (void)saveAction
{
    if (previewView.image) {
        UIImageWriteToSavedPhotosAlbum(previewView.image, nil, nil, nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
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
    return 5;
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
	[previewView setImage:inImage];
}

@synthesize scrollView;
@synthesize previewView;
@synthesize indicatorView;
@end
