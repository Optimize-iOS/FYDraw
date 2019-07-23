//
//  FYCoreTextLinkUtils.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/28.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FYCoreTextLinkData;
@class FYCoreTextData;

@interface FYCoreTextLinkUtils : NSObject

+ (FYCoreTextLinkData *)touchLinkTextInDisplayView:(UIView *)view atPoint:(CGPoint)point data:(FYCoreTextData *)textData;


@end

