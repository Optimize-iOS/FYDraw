//
//  UIView+AdjustFrame.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/25.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "UIView+AdjustFrame.h"

@implementation UIView (AdjustFrame)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}


- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}


- (CGFloat)height {
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}


- (CGFloat)width {
    return self.bounds.size.width;
}

- (void)setWitdth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}


@end
