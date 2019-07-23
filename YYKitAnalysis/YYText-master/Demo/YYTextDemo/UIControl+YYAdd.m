//
//  UIControl+YYAdd.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 13/4/5.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIControl+YYAdd.h"
#import <objc/runtime.h>


static const int block_key;

//设置一个 UI 添加 Target 点击或者是其他类型实现
@interface _YYUIControlBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _YYUIControlBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

//调用
- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end



@implementation UIControl (YYAdd)

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock: ^(id object, BOOL *stop) {
        [self   removeTarget:object
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    }];
}

//对当个控件添加一个事件 在何种操作下相应点击
//删除当前控件中添加的 其他的时间响应的
- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self   removeTarget:currentTarget action:NSSelectorFromString(currentAction)
                forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(id sender))block {
    //把添加的事件临时绑定到 target 中
    _YYUIControlBlockTarget *target = [[_YYUIControlBlockTarget alloc]
                                       initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    
    //懒加载方式创建 UITarget 数组
    NSMutableArray *targets = [self _yy_allUIControlBlockTargets];
    [targets addObject:target];
}

//设置替换在当前 UI 调用的 Target 来做相对应时间的回调
//删除在当前 所有添加到数组中 Targets 中相同的 UIControlEvents 事件
//然后在添加当前相应的方式

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(id sender))block {
    [self removeAllBlocksForControlEvents:controlEvents];
    [self addBlockForControlEvents:controlEvents block:block];
}

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *targets = [self _yy_allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    [targets enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        _YYUIControlBlockTarget *target = (_YYUIControlBlockTarget *)obj;
        if (target.events == controlEvents) {
            [removes addObject:target];
            [self   removeTarget:target
                          action:@selector(invoke:)
                forControlEvents:controlEvents];
        }
    }];
    [targets removeObjectsInArray:removes];
}

// 采用关联对象的方式对拓展添加属性
//
- (NSMutableArray *)_yy_allUIControlBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    //NSMutableArray *tars = objc_getAssociatedObject(self, &block_key);
    
    if (!targets) {
        targets = [NSMutableArray array];
        
        //把当前的属性变量指定 targets 指定给 block_key 值来创建 Category 中属性值
        //
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
