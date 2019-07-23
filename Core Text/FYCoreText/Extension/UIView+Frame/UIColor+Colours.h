//
//  UIColor+Colours.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/26.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (Colours)

+ (instancetype)colorFromHexString:(NSString *)hexString;

- (NSString *)hexString;

@end

