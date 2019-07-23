//
//  FYCoreTextData.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYCoreTextData.h"
#import "FYCoreTextImageData.h"

@implementation FYCoreTextData

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
        
    }
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self fillReplaceCharWithImagePosition];

}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}


#pragma mark - Privated Methods

- (void)fillReplaceCharWithImagePosition {
    if (self.imageArray.count == 0) { return; }
    
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    NSInteger imgIndex = 0;
    FYCoreTextImageData *imageData = self.imageArray[0];
    
    for (int i = 0; i < lineCount; i++) {
        if (imageData == nil) { break; }
        
        CTLineRef lineRef = (__bridge CTLineRef)lines[i];
        NSArray *runsArray = (NSArray *)CTLineGetGlyphRuns(lineRef);
        
        for (id runObj in runsArray) {
            CTRunRef runRef = (__bridge CTRunRef)runObj;
            NSDictionary *runAttribs = (NSDictionary *)CTRunGetAttributes(runRef);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttribs valueForKey:(id)kCTRunDelegateAttributeName];
            
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            
            runBounds.size.width = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateRect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imageRect = delegateRect;
            imgIndex++;
            
            if(imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            }else {
                imageData = self.imageArray[imgIndex];
            }
            
        }
    }
}

@end
