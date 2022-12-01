//
//  NSObject+Invocation.m
//  Modular
//
//  Created by 顾钱想 on 2022/11/29.
//

#import "NSObject+Invocation.h"

@implementation NSObject (Invocation)

/// 执行方法
/// @param cls 类
/// @param sel 方法
/// @param isClassMethod 是否是类方法
/// @param args 参数
/// @param callback 回调
- (nullable id)invocationWithClass:(Class)cls  sel:(SEL)sel isClassMethod:(BOOL) isClassMethod args:(NSArray *)args callback:(void (^ __nullable)(NSDictionary * __nullable))callback {
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
        NSAssert(sig.numberOfArguments-2 == args.count, @"%@.performArgs %@ ,The SEL parameters count is not equal to args parameters count. sel need %lu, but args is %lu",self,NSStringFromSelector(sel),(unsigned long)sig.numberOfArguments-2,(unsigned long)args.count);
        for (int i = 0; i < args.count; i++) {
            id obj = args[i];
            [invocation setArgument:&obj atIndex:i+2];
        }
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

- (BOOL)isSwift{
    return [NSStringFromClass([self class]) componentsSeparatedByString:@"."].count > 1;
}
@end
