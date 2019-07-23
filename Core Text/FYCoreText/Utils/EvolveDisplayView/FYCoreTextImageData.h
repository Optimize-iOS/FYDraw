//
//  FYCoreTextImageData.h
//  FYCoreText
//
//  Created by JackJin on 2019/6/27.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FYCoreTextImageData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGRect imageRect; //Coordinate position in core text

@end

