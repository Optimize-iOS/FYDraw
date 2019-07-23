//
//  FYCoreTextLinkUtils.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/28.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYCoreTextLinkUtils.h"
#import "FYCoreTextData.h"
#import "FYCoreTextLinkData.h"
#import <CoreText/CoreText.h>

@implementation FYCoreTextLinkUtils

+ (FYCoreTextLinkData *)touchLinkTextInDisplayView:(UIView *)view atPoint:(CGPoint)point data:(FYCoreTextData *)textData {
    CTFrameRef frameRef = textData.ctFrame;
    CFArrayRef lines = CTFrameGetLines(frameRef);
    if (!lines) { return nil; }
    
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    //Translateform coordinate
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGRect lineRect = [self gainLineBounds:line linePoint:linePoint];
        CGRect flippedRect = CGRectApplyAffineTransform(lineRect, transform);
        
        if (CGRectContainsPoint(flippedRect, point)) {
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(flippedRect), point.y - CGRectGetMinY(flippedRect));
            CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
            
            return [self linkTextAtIndex:index linkArray:textData.linkArray];
        }
    }
    
    return nil;
}

+ (FYCoreTextLinkData *)linkTextAtIndex:(CFIndex)index linkArray:(NSArray *)linkArray {
    FYCoreTextLinkData *linkData = nil;
    for (FYCoreTextLinkData *data in linkArray) {
        if (NSLocationInRange(index, data.range)) {
            linkData = data;
            break;
        }
    }
    
    return linkData;
}

+ (CGRect)gainLineBounds:(CTLineRef)line linePoint:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(point.x, point.y - descent, width, height);
}


@end
