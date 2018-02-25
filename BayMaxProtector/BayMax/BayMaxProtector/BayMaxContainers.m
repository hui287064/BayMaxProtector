//
//  BayMaxContainers.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/14.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxContainers.h"
#import "BayMaxCFunctions.h"
#import "BayMaxCatchError.h"
#import "BayMaxDebugView.h"
BMPErrorHandler _Nullable _containerErrorHandler;
//错误信息统一处理
#define BMP_Container_ErrorHandler(errorType,errorInfo)\
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
    BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{                                                                                             errorType:errorInfo,                                                                                             BMPErrorCallStackSymbols:callStackSymbolsArr                                                                                             }];\
    if (_containerErrorHandler) {\
        _containerErrorHandler(bmpError);\
    }
//不可变数组越界
#define BMP_Array_BeyondBounds_ErrorHandler(ArrayType,ArrayMethod,Index)\
    NSString *errorInfo = [NSString stringWithFormat:@"*** -[%@ %@]: index %ld beyond bounds [0 .. %ld]",ArrayType,ArrayMethod,Index,self.count];\
    BMP_Container_ErrorHandler(BMPErrorArray_Beyond,errorInfo)

//可变数组越界
#define BMP_ArrayM_BeyondBounds_ErrorHandler(ErrorInfo)\
    BMP_Container_ErrorHandler(BMPErrorArray_Beyond,ErrorInfo)

//可变数组插入Nil元素
#define BMP_ArrayM_NilObject_ErrorHandler(ErrorInfo)\
    BMP_Container_ErrorHandler(BMPErrorArray_NilObject,ErrorInfo)

//不可变字典key或者value为Nil
#define BMP_Dictionary_ErrorHandler(ErrorInfo)\
    BMP_Container_ErrorHandler(BMPErrorDictionary_NilKey,ErrorInfo)
//可变字典key或者value为Nil
#define BMP_DictionaryM_ErrorHandler(ErrorInfo)\
    BMP_Container_ErrorHandler(BMPErrorDictionary_NilKey,ErrorInfo)

@interface NSArray (BMPProtector)

@end

@implementation NSArray (BMPProtector)
// NSArray/__NSArrayI/__NSSingleObjectArrayI/__NSArray0
//objectsAtIndexes:
+ (instancetype)BMP_ArrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull objectsNew[cnt];
    for (int i = 0; i<cnt; i++) {
        if (objects[i]) {
            objectsNew[index] = objects[i];
            index++;
        }else{
            //记录错误
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Container_ErrorHandler(BMPErrorArray_NilObject, errorInfo);
        }
    }
    return [self BMP_ArrayWithObjects:objectsNew count:index];
}

- (NSArray *)BMP_objectsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        if (indexes.firstIndex >= self.count) {
            BMP_Array_BeyondBounds_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return nil;
        }else{
            NSIndexSet *indexesNew = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexes.firstIndex, self.count-indexes.firstIndex)];
            BMP_Array_BeyondBounds_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return [self BMP_objectsAtIndexes:indexesNew];
        }
    }
    return [self BMP_objectsAtIndexes:indexes];
}

//objectAtIndex:
- (id)BMP__NSArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArrayI",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSArrayIObjectAtIndex:index];
}

- (id)BMP__NSSingleObjectArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSSingleObject",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSSingleObjectArrayIObjectAtIndex:index];
}

- (id)BMP__NSArray0ObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArray0",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSArray0ObjectAtIndex:index];
}
@end

@interface NSMutableArray (BMPProtector)

@end

@implementation NSMutableArray (BMPProtector)
//objectAtIndex:
- (id)BMP_MArrayObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArrayM",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP_MArrayObjectAtIndex:index];
}

//removeObjectAtIndex:
- (void)BMP_MArrayRemoveObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM removeObjectsInRange:]: range {%ld, 1} extends beyond bounds [0 .. %ld]",index,self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectAtIndex:index];
}

- (void)BMP_MArrayRemoveObjectsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray removeObjectsAtIndexes:]: index %ld in index set beyond bounds [0 .. %ld]",indexes.lastIndex,self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectsAtIndexes:indexes];
}

- (void)BMP_MArrayRemoveObjectsInRange:(NSRange)range{
    if (range.location >= self.count || range.location+range.length>self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM removeObjectsInRange:]: range {%ld, %ld} extends beyond bounds [0 .. %ld]",range.location,range.length,self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectsInRange:range];
}

//insertObject:atIndex:
- (void)BMP_MArrayInsertObject:(id)anObject atIndex:(NSUInteger)index{
    // -[__NSArrayM insertObject:atIndex:]: object cannot be nil
    if (anObject == nil) {
        BMP_ArrayM_NilObject_ErrorHandler(@"***  -[__NSArrayM insertObject:atIndex:]: object cannot be nil");
        return;
    }
    if (index > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM insertObject:atIndex:]: index %ld beyond bounds [0 .. %ld]",index,self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObject:anObject atIndex:index];
}

- (void)BMP_MArrayInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    if (indexes.firstIndex > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray insertObjects:atIndexes:]: index %ld in index set beyond bounds [0 .. %ld]",indexes.firstIndex,self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }else if (objects.count != (indexes.count)){
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray insertObjects:atIndexes:]: count of array (%ld) differs from count of index set (%ld)",objects.count,indexes.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObjects:objects atIndexes:indexes];
}

@end

@interface NSDictionary (BMPProtector)

@end

@implementation NSDictionary  (BMPProtector)

+ (instancetype)BMP_dictionaryWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    return [self BMP_dictionaryWithObjects:objects forKeys:keys count:cnt];
}

+ (instancetype)BMP_dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys{
    if (objects.count != keys.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSDictionary initWithObjects:forKeys:]: count of objects (%ld) differs from count of keys (%ld)",objects.count,keys.count];
        BMP_Dictionary_ErrorHandler(errorInfo);
        return nil;//huicha
    }
    NSUInteger index = 0;
    id _Nonnull objectsNew[objects.count];
    id <NSCopying> _Nonnull keysNew[keys.count];
    for (int i = 0; i<keys.count; i++) {
        if (objects[i] && keys[i]) {
            objectsNew[index] = objects[i];
            keysNew[index] = keys[i];
            index ++;
        }else{
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Dictionary_ErrorHandler(errorInfo);
        }
    }   
    return [self BMP_dictionaryWithObjects:[NSArray arrayWithObjects:objectsNew count:index] forKeys: [NSArray arrayWithObjects:keysNew count:index]];
}

- (instancetype)BMP_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull objectsNew[cnt];
    id <NSCopying> _Nonnull keysNew[cnt];
    //'*** -[NSDictionary initWithObjects:forKeys:]: count of objects (1) differs from count of keys (0)'
    for (int i = 0; i<cnt; i++) {
        if (objects[i] && keys[i]) {//可能存在nil的情况
            objectsNew[index] = objects[i];
            keysNew[index] = keys[i];
            index ++;
        }else{
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Dictionary_ErrorHandler(errorInfo);
        }
    }
    return [self BMP_initWithObjects:objectsNew forKeys:keysNew count:index];
}

@end

@interface NSMutableDictionary (BMPProtector)

@end

@implementation NSMutableDictionary  (BMPProtector)

//setObject:forKey:
- (void)BMP_dictionaryMSetObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject && aKey) {
        [self BMP_dictionaryMSetObject:anObject forKey:aKey];
    }else{
        NSString *errorInfo;
        if (anObject == nil) {
            errorInfo = @"*** setObjectForKey: object cannot be nil";
        }else if (aKey == nil){
            errorInfo = @"*** setObjectForKey: key cannot be nil";
        }
        BMP_DictionaryM_ErrorHandler(errorInfo);
    }
}

//removeObjectForKey:
- (void)BMP_dictionaryMRemoveObjectForKey:(id)aKey{
    if (aKey) {
        [self BMP_dictionaryMRemoveObjectForKey:aKey];
    }else{
        NSString *errorInfo = @"*** -[__NSDictionaryM removeObjectForKey:]: key cannot be nil";
        BMP_DictionaryM_ErrorHandler(errorInfo);
    }
}

@end

@interface NSString (BMPProtector)

@end

@implementation NSString  (BMPProtector)

@end

@interface NSMutableString (BMPProtector)

@end

@implementation NSMutableString  (BMPProtector)

@end

@implementation BayMaxContainers

+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler{
    _containerErrorHandler = errorHandler;
    //NSArray
    [self exchangeMethodsInNSArray];
    //NSMutableArray
    [self exchangeMethodsInNSMutableArray];
    //NSDictionary
    [self exchangeMethodsInNSDictionary];
    //NSMutableDictionary
    [self exchangeMethodsInNSMutableDictionary];
    //NSString
    [self exchangeMethodsInNSString];
    //NSMutableString
    [self exchangeMethodsInNSMutableString];
}

+ (void)exchangeMethodsInNSArray{
    Class __NSArray = NSClassFromString(@"NSArray");
    Class __NSArrayI = NSClassFromString(@"__NSArrayI");
    Class __NSSingleObjectArrayI = NSClassFromString(@"__NSSingleObjectArrayI");
    Class __NSArray0 = NSClassFromString(@"__NSArray0");
    //insertNil
    BMP_EXChangeClassMethod(__NSArray, @selector(arrayWithObjects:count:), @selector(BMP_ArrayWithObjects:count:));    
    //objectsAtIndexes:
    BMP_EXChangeInstanceMethod(__NSArray, @selector(objectsAtIndexes:), __NSArray, @selector(BMP_objectsAtIndexes:));
    //objectAtIndex:
    BMP_EXChangeInstanceMethod(__NSArrayI, @selector(objectAtIndex:), __NSArrayI, @selector(BMP__NSArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSSingleObjectArrayI, @selector(objectAtIndex:), __NSSingleObjectArrayI, @selector(BMP__NSSingleObjectArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSArray0, @selector(objectAtIndex:), __NSArray0, @selector(BMP__NSArray0ObjectAtIndex:));
}

+ (void)exchangeMethodsInNSMutableArray{
    Class arrayMClass = NSClassFromString(@"__NSArrayM");
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(objectAtIndex:), arrayMClass, @selector(BMP_MArrayObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectAtIndex:), arrayMClass, @selector(BMP_MArrayRemoveObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectsInRange:), arrayMClass, @selector(BMP_MArrayRemoveObjectsInRange:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectsAtIndexes:), arrayMClass, @selector(BMP_MArrayRemoveObjectsAtIndexes:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObject:atIndex:), arrayMClass, @selector(BMP_MArrayInsertObject:atIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObjects:atIndexes:), arrayMClass, @selector(BMP_MArrayInsertObjects:atIndexes:));
}

+ (void)exchangeMethodsInNSDictionary{
    Class dictionaryClass = NSClassFromString(@"NSDictionary");
    Class __NSPlaceholderDictionaryClass = NSClassFromString(@"__NSPlaceholderDictionary");
    BMP_EXChangeClassMethod(dictionaryClass, @selector(dictionaryWithObjects:forKeys:count:), @selector(BMP_dictionaryWithObjects:forKeys:count:));
    BMP_EXChangeInstanceMethod(__NSPlaceholderDictionaryClass, @selector(initWithObjects:forKeys:count:), __NSPlaceholderDictionaryClass, @selector(BMP_initWithObjects:forKeys:count:));
}

+ (void)exchangeMethodsInNSMutableDictionary{
    Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
    BMP_EXChangeInstanceMethod(dictionaryM, @selector(setObject:forKey:), dictionaryM, @selector(BMP_dictionaryMSetObject:forKey:));
    BMP_EXChangeInstanceMethod(dictionaryM, @selector(removeObjectForKey:), dictionaryM, @selector(BMP_dictionaryMRemoveObjectForKey:));
}

+ (void)exchangeMethodsInNSString{
    
}

+ (void)exchangeMethodsInNSMutableString{
    
}

@end


