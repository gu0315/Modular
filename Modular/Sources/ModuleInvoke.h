//
//  ModuleInvoke.h
//  Modular
//
//  Created by 顾钱想 on 2022/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModuleInvoke : NSObject

#pragma mark - 执行方法
- (nullable id)invokeWithParams:(NSDictionary *)params callback:(void (^ __nullable)(NSDictionary * __nullable))callback;

@end

NS_ASSUME_NONNULL_END
