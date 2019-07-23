//
//  FYEvolveDisplayView.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYCoreTextData.h"
#import "FYFrameParser.h"
#import "FYFrameParserConfig.h"
#import "FYCoreTextLinkUtils.h"

@interface FYEvolveDisplayView : UIView

@property (nonatomic, strong) FYCoreTextData *coreTextData;

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end

