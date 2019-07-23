//
//  FYFrameParser.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FYFrameParserConfig.h"
#import "FYCoreTextData.h"
#import "FYCoreTextImageData.h"
#import "FYCoreTextLinkData.h"

@interface FYFrameParser : NSObject

+ (FYCoreTextData *)parseContent:(NSString *)content config:(FYFrameParserConfig *)config;

//有一个小问题 | 在富文本编辑中很难实现对自定义的 字体类型
+ (NSDictionary *)attributesWithConfig:(FYFrameParserConfig *)config;

+ (FYCoreTextData *)parseAttributeContent:(NSAttributedString *)attribContent config:(FYFrameParserConfig *)config;

+ (FYCoreTextData *)parseLocalTemplateFile:(NSString *)path config:(FYFrameParserConfig *)config;

+ (FYCoreTextData *)parseLocalImageTemplateFile:(NSString *)path config:(FYFrameParserConfig *)config;

@end

