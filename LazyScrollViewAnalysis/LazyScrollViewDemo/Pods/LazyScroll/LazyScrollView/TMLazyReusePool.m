//
//  TMLazyReusePool.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyReusePool.h"
#import "UIView+TMLazyScrollView.h"

@interface TMLazyReusePool () {
    NSMutableDictionary<NSString *, NSMutableSet *> *_reuseDict;
}

@end

@implementation TMLazyReusePool

- (instancetype)init
{
    if (self = [super init]) {
        _reuseDict = [NSMutableDictionary dictionary];
    }
    return self;
}

/// 对视图进行缓存能力
//（1）对要保存的 View 添加 identifier 对应 Dictionary<String, MutableSet>
//（2）从保存的字典中获取对应 Mutable，然后从 Mutable 中来获取对应 View 然后从对应中删除
//
- (void)addItemView:(UIView *)itemView forReuseIdentifier:(NSString *)reuseIdentifier
{
    if (reuseIdentifier == nil || reuseIdentifier.length == 0 || itemView == nil) {
        return;
    }
    //通过当前 key: value
    NSMutableSet *reuseSet = [_reuseDict tm_safeObjectForKey:reuseIdentifier];
    ///当前对 identifier 来保存
    if (!reuseSet) {
        reuseSet = [NSMutableSet set];
        [_reuseDict setObject:reuseSet forKey:reuseIdentifier];
    }
    [reuseSet addObject:itemView];
}

- (UIView *)dequeueItemViewForReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self dequeueItemViewForReuseIdentifier:reuseIdentifier andMuiID:nil];
}

- (UIView *)dequeueItemViewForReuseIdentifier:(NSString *)reuseIdentifier andMuiID:(NSString *)muiID
{
    if (reuseIdentifier == nil || reuseIdentifier.length == 0) {
        return nil;
    }
    UIView *result = nil;
    //获取当前 reuseIdentifier 对应的 mutable set
    NSMutableSet *reuseSet = [_reuseDict tm_safeObjectForKey:reuseIdentifier];
    if (reuseSet && reuseSet.count > 0) {
        if (!muiID) {//如果没有对应的 muiID 直接获取其中一个
            result = [reuseSet anyObject];
        } else {
            ///遍历当前对应的 muiID 然后取出对应缓存的视图
            for (UIView *itemView in reuseSet) {
                if ([itemView.muiID isEqualToString:muiID]) {
                    result = itemView;
                    break;
                }
            }
            if (!result) {
                result = [reuseSet anyObject];
            }
        }
        //
        [reuseSet removeObject:result];
    }
    return result;
}

- (void)clear
{
    [_reuseDict removeAllObjects];
}

- (NSSet<UIView *> *)allItemViews
{
    NSMutableSet *result = [NSMutableSet set];
    for (NSMutableSet *reuseSet in _reuseDict.allValues) {
        [result unionSet:reuseSet];
    }
    return [result copy];
}

@end
