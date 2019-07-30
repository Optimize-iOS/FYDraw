//
//  TMLazyScrollView.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyScrollView.h"
#import <objc/runtime.h>
#import "TMLazyItemViewProtocol.h"
#import "TMLazyReusePool.h"
#import "TMLazyModelBucket.h"

#define LazyBufferHeight 20
#define LazyBucketHeight 400
void * const LazyObserverContext = "LazyObserverContext";

@interface TMLazyOuterScrollViewObserver: NSObject

@property (nonatomic, weak) TMLazyScrollView *lazyScrollView;

@end

//****************************************************************

@interface TMLazyScrollView () {
    NSMutableSet<UIView *> *_visibleItems;
    NSMutableSet<NSString *> *_inScreenVisibleMuiIDs;
    
    // Store item models.
    TMLazyModelBucket *_modelBucket;
    NSInteger _itemCount;
    
    // Store muiID of items which need to be reloaded.
    NSMutableSet<NSString *> *_needReloadingMuiIDs;
    
    // Record current muiID of reloading item.
    // Will be used for dequeueReusableItem methods.
    NSString *_currentReloadingMuiID;
    
    // Store muiID of items which should be visible.
    NSMutableSet<NSString *> *_newVisibleMuiIDs;
    
    // Store muiID of items which are visible last time.
    NSSet<NSString *> *_lastInScreenVisibleMuiIDs;
    
    // Store the enter screen times of items.
    NSMutableDictionary<NSString *, NSNumber *> *_enterTimesDict;

    // Record contentOffset of scrollView that used for calculating
    // views to show last time.
    CGPoint _lastContentOffset;
}

//采用在当前 ScrollViewObserver 来实现相互拥有关系
@property (nonatomic, strong) TMLazyOuterScrollViewObserver *outerScrollViewObserver;

- (void)outerScrollViewDidScroll;

@end

@implementation TMLazyScrollView

#pragma mark Getter & Setter

- (NSSet<UIView *> *)inScreenVisibleItems
{
    NSMutableSet<UIView *> * inScreenVisibleItems = [NSMutableSet set];
    for (UIView *view in _visibleItems) {
        if ([_inScreenVisibleMuiIDs containsObject:view.muiID]) {
            [inScreenVisibleItems addObject:view];
        }
    }
    return [inScreenVisibleItems copy];
}

- (NSSet<UIView *> *)visibleItems
{
    return [_visibleItems copy];
}

- (void)setDataSource:(id<TMLazyScrollViewDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        if (dataSource == nil || [self isDataSourceValid:dataSource]) {
            _dataSource = dataSource;
#ifdef DEBUG
        } else {
            NSAssert(NO, @"TMLazyScrollView - Invalid dataSource.");
#endif
        }
    }
}

//初始化当前观察 LazyScrollView 滑动的监听
- (TMLazyOuterScrollViewObserver *)outerScrollViewObserver
{
    if (!_outerScrollViewObserver) {
        _outerScrollViewObserver = [TMLazyOuterScrollViewObserver new];
        _outerScrollViewObserver.lazyScrollView = self;
    }
    return _outerScrollViewObserver;
}

-(void)setOuterScrollView:(UIScrollView *)outerScrollView
{
    if (_outerScrollView != outerScrollView) {
        if (_outerScrollView) {
            [_outerScrollView removeObserver:self.outerScrollViewObserver forKeyPath:@"contentOffset" context:LazyObserverContext];
        }
        if (outerScrollView) {
            [outerScrollView addObserver:self.outerScrollViewObserver forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:LazyObserverContext];
        }
        _outerScrollView = outerScrollView;
    }
}

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _autoClearGestures = YES; //
        _loadAllItemsImmediately = YES;
        
        //TODO
        _reusePool = [TMLazyReusePool new];
        
        _visibleItems = [[NSMutableSet alloc] init];
        
        _inScreenVisibleMuiIDs = [NSMutableSet set];
        
        //TODO 设置当前 model bucket 的高度 
        _modelBucket = [[TMLazyModelBucket alloc] initWithBucketHeight:LazyBucketHeight];
        
        _needReloadingMuiIDs = [[NSMutableSet alloc] init];
        
        _enterTimesDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
    self.outerScrollView = nil;
}

#pragma mark ScrollEvent

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    //判断当前滑动的距离当前大于 20 就聚集一次对应的 Views
    if (LazyBufferHeight < ABS(contentOffset.y - _lastContentOffset.y)) {
        _lastContentOffset = self.contentOffset;
        [self assembleSubviews:NO];
    }
}

//TODO 当前的在外部父 View 类 ScrollView 滑动
- (void)outerScrollViewDidScroll
{
    if (self.outerScrollView) {
        //把一个 View 的坐标转换到另一个 View 的坐标点
        CGPoint contentOffset = [self.outerScrollView convertPoint:self.outerScrollView.contentOffset toView:self];
        if (LazyBufferHeight < ABS(contentOffset.y - _lastContentOffset.y)) {
            _lastContentOffset = contentOffset;
            [self assembleSubviews:NO];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self outerScrollViewDidScroll];
}

#pragma mark CoreLogic

- (void)assembleSubviews:(BOOL)isReload
{
    if (self.outerScrollView) {
        //将当前在的坐标系转换为 在点击响应的坐标系统
        CGRect frame = [self.superview convertRect:self.frame toView:self.outerScrollView];
        CGRect visibleArea = CGRectIntersection(self.outerScrollView.bounds, frame);
        if (visibleArea.size.height > 0) {
            CGFloat offsetY = CGRectGetMinY(frame);
            CGFloat minY = CGRectGetMinY(visibleArea) - offsetY;
            CGFloat maxY = CGRectGetMaxY(visibleArea) - offsetY;
            [self assembleSubviews:isReload minY:minY maxY:maxY];
        } else {
            [self assembleSubviews:isReload minY:0 maxY:-LazyBufferHeight * 2];
        }
    } else {
        CGFloat minY = CGRectGetMinY(self.bounds);
        CGFloat maxY = CGRectGetMaxY(self.bounds);
        [self assembleSubviews:isReload minY:minY maxY:maxY];
    }
}

- (void)recycleItems:(BOOL)isReload newVisibleMuiIDs:(NSSet<NSString *> *)newVisibleMuiIDs
{
    ///可视的 items
    NSSet *visibleItemsCopy = [_visibleItems copy];
    for (UIView *itemView in visibleItemsCopy) {
        ///可展示的 muiID
        BOOL isToShow  = [newVisibleMuiIDs containsObject:itemView.muiID];
        if (!isToShow) {
            // Call didLeave.
            //
            if ([itemView respondsToSelector:@selector(mui_didLeave)]){
                [(UIView<TMLazyItemViewProtocol> *)itemView mui_didLeave];
            }
            ///不展示 add 到缓存中
            if (itemView.reuseIdentifier.length > 0) {
                itemView.hidden = YES;
                [self.reusePool addItemView:itemView forReuseIdentifier:itemView.reuseIdentifier];
                [_visibleItems removeObject:itemView];
            } else if(isReload && itemView.muiID) {
                [_needReloadingMuiIDs addObject:itemView.muiID];
            }
        } else if (isReload && itemView.muiID) {
            [_needReloadingMuiIDs addObject:itemView.muiID];
        }
    }
}

- (void)generateItems:(BOOL)isReload
{
    ///
    if (_newVisibleMuiIDs == nil || _newVisibleMuiIDs.count == 0) {
        return;
    }
    
    NSString *muiID = [_newVisibleMuiIDs anyObject];
    BOOL hasLoadAnItem = NO;
    
    // 1. Item view is not visible. We should create or reuse an item view.
    // 2. Item view need to be reloaded.
    ///
    ///
    BOOL isVisible = [self isMuiIdVisible:muiID];
    BOOL needReload = [_needReloadingMuiIDs containsObject:muiID];
    //
    if (isVisible == NO || needReload == YES) {
        if (self.dataSource) {
            hasLoadAnItem = YES;
            
            // If you call dequeue method in your dataSource, the currentReloadingMuiID
            // will be used for searching the best-matched reusable view.
            if (isVisible == YES) {
                _currentReloadingMuiID = muiID;
            }
            //获取对应的 muiID 来或许绘制的 View
            UIView *itemView = [self.dataSource scrollView:self itemByMuiID:muiID];
            _currentReloadingMuiID = nil;
            
            if (itemView) {
                // Call afterGetView.
                if ([itemView respondsToSelector:@selector(mui_afterGetView)]) {
                    [(UIView<TMLazyItemViewProtocol> *)itemView mui_afterGetView];
                }
                // Show the item view.
                itemView.muiID = muiID;
                itemView.hidden = NO;
                if (self.autoAddSubview) {
                    if (itemView.superview != self) {
                        [self addSubview:itemView];
                    }
                }
                // Add item view to visibleItems.
                if (isVisible == NO) {
                    [_visibleItems addObject:itemView];
                }
            }
            
            [_needReloadingMuiIDs removeObject:muiID];
        }
    }
    
    // Call didEnterWithTimes.
    // didEnterWithTimes will only be called when item view enter the in screen
    // visible area, so we have to write the logic at here.
    if ([_lastInScreenVisibleMuiIDs containsObject:muiID] == NO
     && [_inScreenVisibleMuiIDs containsObject:muiID] == YES) {
        for (UIView *itemView in _visibleItems) {
            if ([itemView.muiID isEqualToString:muiID]) {
                if ([itemView respondsToSelector:@selector(mui_didEnterWithTimes:)]) {
                    NSInteger times = [_enterTimesDict tm_integerForKey:itemView.muiID];
                    times++;
                    [_enterTimesDict tm_safeSetObject:@(times) forKey:itemView.muiID];
                    [(UIView<TMLazyItemViewProtocol> *)itemView mui_didEnterWithTimes:times];
                }
                break;
            }
        }
    }
    
    [_newVisibleMuiIDs removeObject:muiID];
    if (_newVisibleMuiIDs.count > 0) {
        if (isReload == YES || self.loadAllItemsImmediately == YES || hasLoadAnItem == NO) {
            [self generateItems:isReload];
        } else {
            ///TODO
            [self performSelector:@selector(generateItems:)
                       withObject:@(isReload)
                       afterDelay:0.0000001
                          inModes:@[NSRunLoopCommonModes]];
        }
    }
}

//TODO TODO
- (void)assembleSubviews:(BOOL)isReload minY:(CGFloat)minY maxY:(CGFloat)maxY
{
    // Calculate which item views should be shown.
    // Calculating will cost some time, so here is a buffer for reducing
    // times of calculating.
    //获取需要展示的 model
    NSSet<TMLazyItemModel *> *newVisibleModels = [_modelBucket showingModelsFrom:minY - LazyBufferHeight
                                                                              to:maxY + LazyBufferHeight];
    ///
    NSSet<NSString *> *newVisibleMuiIDs = [newVisibleModels valueForKey:@"muiID"];

    // Find if item views are in visible area.
    // Recycle invisible item views.
    ///根据展示的区域 获取对应的 muiIDs
    [self recycleItems:isReload newVisibleMuiIDs:newVisibleMuiIDs];
    
    // Calculate the inScreenVisibleModels.
    _lastInScreenVisibleMuiIDs = [_inScreenVisibleMuiIDs copy];
    [_inScreenVisibleMuiIDs removeAllObjects];
    ///删除上一屏展示的内容，然后重新加载
    for (TMLazyItemModel *itemModel in newVisibleModels) {
        if (itemModel.top < maxY && itemModel.bottom > minY) {
            [_inScreenVisibleMuiIDs addObject:itemModel.muiID];
        }
    }
    
    // Generate or reload visible item views.
    // 所有执行请求都被取消，这些请求的目标与aTarget相同，参数与参数相同，选择器与选择器相同。此方法仅删除当前运行循环中的执行请求，而不是所有运行循环。
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(generateItems:) object:@(NO)];
    _newVisibleMuiIDs = [newVisibleMuiIDs mutableCopy];
    //
    [self generateItems:isReload];
}

#pragma mark Reload

- (void)storeItemModelsFromIndex:(NSInteger)startIndex
{
    if (startIndex == 0) {
        _itemCount = 0;
        [_modelBucket clear];//清除当前 model 桶
    }
    //
    if (self.dataSource) {
        //获取当前数目的数量 | 控件的数目
        _itemCount = [self.dataSource numberOfItemsInScrollView:self];
        for (NSInteger index = startIndex; index < _itemCount; index++) {
            ///遍历当前 data source 添加对应的 model
            TMLazyItemModel *itemModel = [self.dataSource scrollView:self itemModelAtIndex:index];
            if (itemModel.muiID.length == 0) {
                itemModel.muiID = [NSString stringWithFormat:@"%zd", index];
            }
            [_modelBucket addModel:itemModel];
        }
    }
}

//重新加载数据 assemble 组装
- (void)reloadData
{
    [self storeItemModelsFromIndex:0];
    [self assembleSubviews:YES];
}

//添加 more data
- (void)loadMoreData
{
    [self storeItemModelsFromIndex:_itemCount];
    [self assembleSubviews:NO];
}

- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    return [self dequeueReusableItemWithIdentifier:identifier muiID:nil];
}

- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier muiID:(NSString *)muiID
{
    UIView *result = nil;
    if (_currentReloadingMuiID) {
        for (UIView *item in _visibleItems) {
            if ([item.muiID isEqualToString:_currentReloadingMuiID]
             && [item.reuseIdentifier isEqualToString:identifier]) {
                result = item;
                break;
            }
        }
    }
    if (result == nil) {
        result = [self.reusePool dequeueItemViewForReuseIdentifier:identifier andMuiID:muiID];
    }
    if (result) {
        if (self.autoClearGestures) {
            result.gestureRecognizers = nil;
        }
        if ([result respondsToSelector:@selector(mui_prepareForReuse)]) {
            [(UIView<TMLazyItemViewProtocol> *)result mui_prepareForReuse];
        }
    }
    return result;
}

#pragma mark Clear & Reset

- (void)clearVisibleItems:(BOOL)enableRecycle
{
    if (enableRecycle) {
        for (UIView *itemView in _visibleItems) {
            itemView.hidden = YES;
            if (itemView.reuseIdentifier.length > 0) {
                [self.reusePool addItemView:itemView forReuseIdentifier:itemView.reuseIdentifier];
            }
        }
    } else {
        for (UIView *itemView in _visibleItems) {
            [itemView removeFromSuperview];
        }
    }
    [_visibleItems removeAllObjects];
}

- (void)removeAllLayouts
{
    [self clearVisibleItems:YES];
}

- (void)clearReuseItems
{
    for (UIView *itemView in [self.reusePool allItemViews]) {
        [itemView removeFromSuperview];
    }
    [self.reusePool clear];
}

- (void)cleanRecycledView
{
    [self clearReuseItems];
}

- (void)resetItemsEnterTimes
{
    [_enterTimesDict removeAllObjects];
}

- (void)resetViewEnterTimes
{
    [self resetItemsEnterTimes];
}

- (void)resetAll
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(generateItems:) object:@(NO)];
    [self clearVisibleItems:NO];
    [self clearReuseItems];
    [self resetItemsEnterTimes];
}

- (void)removeContentOffsetObserver
{
    self.outerScrollView = nil;
}

- (void)reLayout
{
    [self reloadData];
}

#pragma mark Private

- (BOOL)isMuiIdVisible:(NSString *)muiID
{
    for (UIView *itemView in _visibleItems) {
        if ([itemView.muiID isEqualToString:muiID]) {
            return YES;
        }
    }
    return NO;
}

///当前三个协议必须全部实现 | 这样才可以实现对应数据
- (BOOL)isDataSourceValid:(id<TMLazyScrollViewDataSource>)dataSource
{
    return dataSource
        && [dataSource respondsToSelector:@selector(numberOfItemsInScrollView:)]
        && [dataSource respondsToSelector:@selector(scrollView:itemModelAtIndex:)]
        && [dataSource respondsToSelector:@selector(scrollView:itemByMuiID:)];
}

@end

//****************************************************************

@implementation TMLazyOuterScrollViewObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LazyObserverContext && [keyPath isEqualToString:@"contentOffset"] && _lazyScrollView) {
        [_lazyScrollView outerScrollViewDidScroll];
    }
}

@end
