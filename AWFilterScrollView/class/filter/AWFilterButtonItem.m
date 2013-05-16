//
//  AWFilterButtonItem.m
//  AWFilterScrollView
//
//  Created by Abe on 13/5/15.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWFilterButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation AWFilterButtonItem
{
	UIActivityIndicatorView *indicatorView;
	CIFilter *filter;
	UIImageView *previewImageView;
}

- (void)dealloc
{
	[originalImage release]; originalImage = nil;
	[name release]; name = nil;
	[filter release]; filter = nil;
	[indicatorView release]; indicatorView = nil;
	[previewImageView release]; previewImageView = nil;
	[super dealloc];
}
- (id)initWithType:(AWFilterType)inType;
{
    self = [super init];
    if (self) {
        type = inType;
		[self _init];
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        type = AWFilterTypeNormal;
		[self _init];
    }
    return self;
}
- (void)_init
{
	self.backgroundColor = [UIColor clearColor];
    
    self.layer.backgroundColor = [UIColor grayColor].CGColor;
	self.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 10.0;

	previewImageView = [[UIImageView alloc] init];
	previewImageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
	previewImageView.layer.contentsScale = [UIScreen mainScreen].scale;
	[self addSubview:previewImageView];

	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	indicatorView.hidesWhenStopped = YES;
	[indicatorView stopAnimating];
	[self addSubview:indicatorView];

	// Initial filter
	switch (type) {
		case AWFilterTypeNormal:
			filter = nil;
			break;
		case AWFilterTypeSepiaTone:
			filter = [[CIFilter filterWithName:@"CISepiaTone"] retain];
			[filter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];
			break;
		case AWFilterTypeToneCurve:
			filter = [[CIFilter filterWithName:@"CIToneCurve"] retain];
			[filter setValue:[CIVector vectorWithX:0.0 Y:0.0] forKey:@"inputPoint0"];
			[filter setValue:[CIVector vectorWithX:0.27 Y:0.26] forKey:@"inputPoint1"];
			[filter setValue:[CIVector vectorWithX:0.5 Y:0.8] forKey:@"inputPoint2"];
			[filter setValue:[CIVector vectorWithX:0.7 Y:1.0] forKey:@"inputPoint3"];
			[filter setValue:[CIVector vectorWithX:1.0 Y:1.0] forKey:@"inputPoint4"];
			break;
		case AWFilterTypeVibrance:
			filter = [[CIFilter filterWithName:@"CIVibrance"] retain];
			[filter setValue:[NSNumber numberWithFloat:35.0] forKey:@"inputAmount"];
			break;
		case AWFilterTypeVignette:
			filter = [[CIFilter filterWithName:@"CIVignette"] retain];
			[filter setValue:[NSNumber numberWithFloat:13.0] forKey:@"inputRadius"];
			[filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputIntensity"];
			break;
	}
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	indicatorView.frame = CGRectMake((self.bounds.size.width - 20.0) / 2, (self.bounds.size.height - 30.0) / 2, 20.0, 20.0);
	[indicatorView startAnimating];
	
	[[UIColor whiteColor] set];
	[name drawInRect:CGRectMake(0.0, self.bounds.size.height - 20.0, self.bounds.size.width, 20.0) withFont:[UIFont boldSystemFontOfSize:12.0] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];

	UIImage *image = [self _resizeOriginalImage];
	CGRect imageRect = CGRectMake((self.bounds.size.width - image.size.width) / 2, (self.bounds.size.height - image.size.height) / 2 - 8.0, image.size.width, image.size.height);

	previewImageView.frame = imageRect;

	// Normal
	if (!filter) {
		[previewImageView setImage:image];
		[indicatorView stopAnimating];
		return;
	}

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		CIContext *context = [CIContext contextWithOptions:nil];
		[filter setValue:[CIImage imageWithCGImage:image.CGImage] forKey:@"inputImage"];
		CIImage *outputCIImage = [filter outputImage];
		CGImageRef imageRef = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
		UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);

		dispatch_async(dispatch_get_main_queue(), ^{
			[previewImageView setImage:outputImage];
			[indicatorView stopAnimating];
		});
	});
}

- (UIImage *)_resizeOriginalImage
{
	CGSize size;
	if (originalImage.size.width >= originalImage.size.height && originalImage.size.width > self.bounds.size.width - 12.0) {
		size = CGSizeMake(self.bounds.size.width - 12.0, originalImage.size.height * ((self.bounds.size.width - 12.0) / originalImage.size.width));
	}
	else if (originalImage.size.width < originalImage.size.height && originalImage.size.height > self.bounds.size.width - 30.0) {
		size = CGSizeMake(originalImage.size.width * ((self.bounds.size.height - 30.0) / originalImage.size.height), self.bounds.size.height - 30.0);
	}
	else {
		size = originalImage.size;
	}

	UIGraphicsBeginImageContext(size);
	[originalImage drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}

- (void)outputImageWithDelegate:(id<AWFilterButtonItemDelegate>)inDelegate
{
	[inDelegate filterButtonItemImageOutputWillBegin:self];
	[indicatorView startAnimating];

	// Normal
	if (!filter) {
		[indicatorView stopAnimating];
		[inDelegate filterButtonItem:self imageOutputDidEndWithImage:originalImage];
		return;
	}

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		UIGraphicsBeginImageContext(originalImage.size);
		[originalImage drawInRect:CGRectMake(0.0, 0.0, originalImage.size.width, originalImage.size.height)];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		CIContext *context = [CIContext contextWithOptions:nil];
		[filter setValue:[CIImage imageWithCGImage:image.CGImage] forKey:@"inputImage"];
		CIImage *outputCIImage = [filter outputImage];
		CGImageRef imageRef = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
		UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);

		dispatch_async(dispatch_get_main_queue(), ^{
			[indicatorView stopAnimating];
			[inDelegate filterButtonItem:self imageOutputDidEndWithImage:outputImage];
		});
	});

}

@synthesize type;
@synthesize originalImage;
@synthesize name;
@end
