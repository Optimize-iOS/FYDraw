//
//  FYEvolveDisplayView.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYEvolveDisplayView.h"


@interface FYEvolveDisplayView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIGestureRecognizer *tapGestureRecognizer;

@end


@implementation FYEvolveDisplayView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self deployGestureRecognizer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self deployGestureRecognizer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    if (self.coreTextData) {
        CTFrameDraw(self.coreTextData.ctFrame, contextRef);
    }
    
    for (FYCoreTextImageData *imageData in self.coreTextData.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        
        if (image) {
            //CGRect rect = imageData.imageRect;
            //NSLog(@"image data rect in display view: x:%f y:%f height:%f width:%f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
            
            CGContextDrawImage(contextRef, imageData.imageRect, image.CGImage);
        }
    }
}


#pragma mark - Configure Heriarchy View

- (void)deployGestureRecognizer {
    [self addGestureRecognizer:self.tapGestureRecognizer];
    self.userInteractionEnabled = YES;
}


#pragma mark - Private Methods

- (void)clickComposeImageInDisplayView:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    
    for (FYCoreTextImageData *imageData in self.coreTextData.imageArray) {
        CGRect imageRect = imageData.imageRect;
        CGPoint imagePosCoreText = imageRect.origin;
        
        imagePosCoreText.y = self.bounds.size.height - imagePosCoreText.y - imageRect.size.height;
        CGRect rectInScreen = CGRectMake(imagePosCoreText.x, imagePosCoreText.y, imageRect.size.width, imageRect.size.height);
        
        if (CGRectContainsPoint(rectInScreen, point)) {
            NSLog(@"Click image of name: %@ url: %@", imageData.name, imageData.url);
        }
    }
    
    FYCoreTextLinkData *linkData = [FYCoreTextLinkUtils touchLinkTextInDisplayView:self atPoint:point data:self.coreTextData];
    
    if (linkData) {
        NSLog(@"Click Link Text. The title is: %@, The Url is %@", linkData.title, linkData.url);
    }
}


#pragma mark - Lazying

- (UIGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickComposeImageInDisplayView:)];
        _tapGestureRecognizer.delegate = self;
    }
    
    return _tapGestureRecognizer;
}


@end
