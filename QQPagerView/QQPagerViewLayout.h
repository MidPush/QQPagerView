//
//  QQPagerViewLayout.h
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import "QQPagerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQPagerViewLayout : UICollectionViewLayout

- (void)forceInvalidate;
- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath;
- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) BOOL needsReprepare;
@property (nonatomic, assign) CGFloat itemSpacing;

@end

NS_ASSUME_NONNULL_END
