//
//  FYFrameParser.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYFrameParser.h"
#import "UIColor+Colours.h"

static CGFloat ascentCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}


@implementation FYFrameParser

+ (FYCoreTextData *)parseContent:(NSString *)content config:(FYFrameParserConfig *)config {
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    return [self parseAttributeContent:contentString config:config];;
}

+ (FYCoreTextData *)parseAttributeContent:(NSAttributedString *)attribContent config:(FYFrameParserConfig *)config {
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attribContent);
    
    //绘制高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成 CTFrameRef
    CTFrameRef frameRef = [self createFrameRefWithFrameSetter:frameSetter config:config height:textHeight];
    
    FYCoreTextData *coreTextData = [[FYCoreTextData alloc] init];
    coreTextData.ctFrame = frameRef;
    coreTextData.height = textHeight;
    
    CFRelease(frameRef);
    CFRelease(frameSetter);
    
    return coreTextData;
}

+ (FYCoreTextData *)parseLocalTemplateFile:(NSString *)path config:(FYFrameParserConfig *)config {
    NSAttributedString *templateAttrib = [self loadLocalTemplateFile:path config:config];
    
    return [self parseAttributeContent:templateAttrib config:config];
}

+ (FYCoreTextData *)parseLocalImageTemplateFile:(NSString *)path config:(FYFrameParserConfig *)config {
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *imageTemplateAttrib  = [self loadLocalTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    
    FYCoreTextData *coreTextData = [self parseAttributeContent:imageTemplateAttrib config:config];
    coreTextData.imageArray = imageArray;
    coreTextData.linkArray = linkArray;
    
    return coreTextData;
}

+ (NSDictionary *)attributesWithConfig:(FYFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    
    CGFloat lineSpace = config.lineSpace;
    
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting styleSetting[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpace}
    };
    
    CTParagraphStyleRef paragrStyleRef = CTParagraphStyleCreate(styleSetting, kNumberOfSettings);
    
    UIColor *textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragrStyleRef;
    
    CFRelease(paragrStyleRef);
    CFRelease(fontRef);
    
    return dict;
}


#pragma mark - Private Method

+ (CTFrameRef)createFrameRefWithFrameSetter:(CTFramesetterRef)frameSetterref
                                     config:(FYFrameParserConfig *)config
                                     height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterref, CFRangeMake(0, 0), path, NULL);
    
    CFRelease(path);
    
    return frameRef;
}


#pragma mark -Local Template

+ (NSAttributedString *)loadLocalTemplateFile:(NSString *)path config:(FYFrameParserConfig *)config {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *mutableAttrib = [[NSMutableAttributedString alloc] init];
    
    if (data) {
        NSArray *templateArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([templateArray isKindOfClass: [NSArray class]]) {
            for (NSDictionary *dic in templateArray) {
                NSString *typeDic = dic[@"type"];
                if ([typeDic isEqualToString: @"txt"]) {
                    NSAttributedString *attribStr = [self parseAttributedContentFormDictionary:dic config:config];
                    
                    [mutableAttrib appendAttributedString:attribStr];
                }
            }
        }
    }
    
    return mutableAttrib;
}

+ (NSAttributedString *)parseAttributedContentFormDictionary:(NSDictionary *)dict config:(FYFrameParserConfig *)config {
    NSMutableDictionary *attribDic = [[self attributesWithConfig:config] mutableCopy];
    
    //Color
    UIColor *color = [UIColor colorFromHexString:dict[@"color"]];
    if (color) {
        attribDic[(id)kCTForegroundColorAttributeName] = (__bridge id)color.CGColor;
    }
    
    //Size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attribDic[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    
    NSString *content = dict[@"content"];
    
    return [[NSAttributedString alloc] initWithString:content attributes:attribDic];
}


#pragma mark -Local Image Template

+ (NSAttributedString *)loadLocalTemplateFile:(NSString *)path
                                       config:(FYFrameParserConfig *)config
                                   imageArray:(NSMutableArray *)imageArray
                                    linkArray:(NSMutableArray *)linkArray {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *mutableAttrib = [[NSMutableAttributedString alloc] init];
    
    if (data) {
        NSArray *templateArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([templateArray isKindOfClass: [NSArray class]]) {
            for (NSDictionary *dic in templateArray) {
                NSString *typeDic = dic[@"type"];
                if ([typeDic isEqualToString: @"txt"]) {
                    NSAttributedString *textAttrib = [self parseAttributedContentFormDictionary:dic config:config];
                    [mutableAttrib appendAttributedString:textAttrib];
                    
                }else if ([typeDic isEqualToString: @"img"]) {
                    NSAttributedString *imageAttrib = [self parseImageDataFromDictionary:dic config:config];
                    [mutableAttrib appendAttributedString:imageAttrib];
                    
                    FYCoreTextImageData *imageData = [[FYCoreTextImageData alloc] init];
                    imageData.name = dic[@"name"];
                    imageData.url = dic[@"url"];
                    imageData.position = mutableAttrib.length;
                    
                    [imageArray addObject:imageData];
                }else if([typeDic isEqualToString:@"link"]){
                    NSUInteger startLoc = mutableAttrib.length;
                    
                    NSAttributedString *linkAttrib = [self parseAttributedContentFormDictionary:dic config:config];
                    [mutableAttrib appendAttributedString:linkAttrib];
                    
                    FYCoreTextLinkData *linkData = [[FYCoreTextLinkData alloc] init];
                    NSUInteger len = mutableAttrib.length - startLoc;
                    NSRange range = NSMakeRange(startLoc, len);
                    linkData.range = range;
                    linkData.title = dic[@"content"];
                    linkData.url = dic[@"url"];
                    
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    
    return mutableAttrib;
}

+ (NSAttributedString *)parseImageDataFromDictionary:(NSDictionary *)dict
                                              config:(FYFrameParserConfig *)config {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    unichar objectReplaceChar = 0xFFCC;
    NSString *conetnt = [NSString stringWithCharacters:&objectReplaceChar length:1];
    
    NSDictionary *attrib = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:conetnt attributes:attrib];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegateRef);
    
    CFRelease(delegateRef);
    
    return space;
}

@end
