//
//  FYCoreTextData.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface FYCoreTextData : NSObject

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *linkArray;

@end

