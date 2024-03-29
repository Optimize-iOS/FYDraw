//
//  UIView+TMLazyScrollView.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (TMLazyScrollView)

@property (nonatomic, copy) NSString *muiID;
@property (nonatomic, copy) NSString *reuseIdentifier; //在 reuseIdentifer 在相同的基础上就会采用复用原则 

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end
