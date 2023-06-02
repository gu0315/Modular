//
//  NSObject+Invocation.m
//  Modular
//
//  Created by 顾钱想 on 2023/6/1.
//

#import "NSObject+Invocation.h"
#import "Modular-Swift.h"

@implementation NSObject (Invocation)

/// 执行方法
/// @param cls 类
/// @param sel 方法
/// @param isClassMethod 是否是类方法
/// @param params 参数
/// @param callback 回调
- (nullable id)invocationWithClass:(Class)cls  sel:(SEL)sel isClassMethod:(BOOL) isClassMethod params:(NSDictionary *)params callback:(void (^ __nullable)(NSDictionary * __nullable))callback {
    id module;
    id returnOb;
    NSMethodSignature *sig;
    if (isClassMethod) {
        module = cls;
        sig = [cls methodSignatureForSelector:sel];
    } else {
        module = [[cls alloc] init];
        sig = [module methodSignatureForSelector:sel];
    }
    if (sig) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.selector = sel;
        invocation.target = module;
        

        [invocation retainArguments];
        [invocation invoke];
        //返回值判断
        NSUInteger length = sig.methodReturnLength;
        NSString *type = [NSString stringWithUTF8String:sig.methodReturnType];
        if (length > 0
            && [type isEqualToString:@"@"]) {
            void *buffer;
            [invocation getReturnValue:&buffer];
            returnOb = (__bridge id)(buffer);
        }
    }
    return returnOb;
}
@end
