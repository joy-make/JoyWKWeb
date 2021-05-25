//
//  UrlFiltManager.h
//  WKWebDemo
//
//  Created by Joymake on 2019/8/23.
//  Copyright © 2019 IB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UrlFiltManager : NSObject
+ (instancetype)shareInstance;
@property (nonatomic,readonly)NSMutableSet *urlFiltSet;

- (void)configUrlFilt:(NSArray *)urlFitArray;

@end

NS_ASSUME_NONNULL_END
