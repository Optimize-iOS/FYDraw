//
//  FYCoreTextLinkData.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/28.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FYCoreTextLinkData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) NSRange range;

@end


