//
//  PLImage.m
//  PLImage
//
//  Created by Lings on 12-7-24.
//  Copyright (c) 2012年 Palmlife.me. All rights reserved.
//

#import "PLImage.h"

// Singleton Macro
#define PL_SINGLETON_GENERATOR(class_name, shared_func_name)    \
static class_name * s_##class_name = nil;                       \
+ (class_name *)shared_func_name                                \
{                                                               \
static dispatch_once_t once;                                \
dispatch_once(&once, ^{                                     \
s_##class_name = [[super allocWithZone:NULL] init];     \
});                                                         \
return s_##class_name;                                      \
}                                                               \
+ (class_name *)allocWithZone:(NSZone *)zone                    \
{                                                               \
return s_##class_name;                                      \
}                                                               \
- (class_name *)copyWithZone:(NSZone *)zone                     \
{                                                               \
return self;                                                \
}                                                               \

#define PL_SINGLETON_SHARED_INSTANCE(class_name)    s_##class_name

#define PL_SINGLETON_CHECK_INITED(class_name)                   \
{if (PL_SINGLETON_SHARED_INSTANCE(class_name)) return PL_SINGLETON_SHARED_INSTANCE(class_name);}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface PLImageManager : NSObject
{
    NSMutableDictionary * _imageWeakMap;
}

+ (PLImageManager *)sharedManager;

- (PLImage *)imageForKey:(NSString *)key;
- (void)setImage:(PLImage *)image forKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key;
- (void)removeAllImages;

@end


@implementation PLImageManager

PL_SINGLETON_GENERATOR(PLImageManager, sharedManager);

- (id)init
{
    PL_SINGLETON_CHECK_INITED(PLImageManager)
    
    if (self = [super init])
    {
        // create weak reference dictionary
        CFDictionaryValueCallBacks valueCallBacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
        _imageWeakMap = (__bridge NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &valueCallBacks);
    }
    
    return self;
}

- (PLImage *)imageForKey:(NSString *)key
{
    return [_imageWeakMap objectForKey:key];
}

- (void)setImage:(PLImage *)image forKey:(NSString *)key
{
    if (!image) {
        return;
    }
    
    [_imageWeakMap setObject:image forKey:key];
}

- (void)removeImageForKey:(NSString *)key
{
    [_imageWeakMap removeObjectForKey:key];
}

- (void)removeAllImages
{
    [_imageWeakMap removeAllObjects];
}


@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


@implementation PLImage

@synthesize imageName = _imageName;

- (id)initWithName:(NSString *)name
{
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    
    if (!imagePath) {
        imagePath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"png"];
    }
    
    if (!imagePath) {
        imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    }
    
    if (self = [super initWithContentsOfFile:imagePath]) {
        _imageName = name;
    }
    
    return self;
}

+ (PLImage *)imageNamed:(NSString *)name
{
    if (!name || !name.length) {
        return nil;
    }
    
    // try to get from map
    PLImage * cacheImg = [[PLImageManager sharedManager] imageForKey:name];
    if (cacheImg) {
        return cacheImg;
    }
    
    PLImage * image = [[self alloc] initWithName:name];
    if (!image) {
        return nil;
    }
    
    // add to map
    [[PLImageManager sharedManager] setImage:image forKey:name];
    
    return image;
}

- (void)dealloc
{
    // remove from map
    if (_imageName) {
        [[PLImageManager sharedManager] removeImageForKey:_imageName];
    }
}


@end

