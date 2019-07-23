//
//  FYDisplayView.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/21.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYDisplayView.h"
#import <CoreText/CoreText.h>

@implementation FYDisplayView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Step 1
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Step 2
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Step 3
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // Step 4
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Hello world! Welcome to learn RICH TEXT knowladge."];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attString.length), path, NULL);
    
    // Step 5
    CTFrameDraw(frame, context);
    
    // Step 6
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}


@end
