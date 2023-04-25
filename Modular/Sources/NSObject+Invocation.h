//
//  NSObject+Invocation.h
//  Modular
//
//  Created by 顾钱想 on 2022/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Invocation)

/// 执行方法
/// @param cls 类
/// @param sel 方法
/// @param isClassMethod 是否是类方法
/// @param args 参数
/// @param callback 回调
- (nullable id)invocationWithClass:(Class)cls  sel:(SEL)sel isClassMethod:(BOOL) isClassMethod args:(NSArray *)args callback:(void (^ __nullable)(NSDictionary * __nullable))callback;

@end

NS_ASSUME_NONNULL_END
