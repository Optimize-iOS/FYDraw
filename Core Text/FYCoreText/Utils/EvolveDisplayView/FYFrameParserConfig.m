//
//  FYFrameParserConfig.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYFrameParserConfig.h"

@implementation FYFrameParserConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _width = 150;
        _fontSize = 14;
        _lineSpace = 6;
        _textColor = RGB(120, 120, 120);
    }
    
    return self;
}

@end
