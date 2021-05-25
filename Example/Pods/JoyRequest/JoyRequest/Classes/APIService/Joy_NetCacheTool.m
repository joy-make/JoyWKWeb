//
//  DataCacheService.m
//
//  Created by Pang Zhenyu on 10-12-31.
//  Copyright 2010 Tenfen Inc. All rights reserved.
//

#import "Joy_NetCacheTool.h"
#import <CommonCrypto/CommonDigest.h>

@interface Joy_NetCacheTool()

-(void) checkCacheDirectories;
-(NSString*) fullPathForKey:(NSString*)key;

@end


#define DIRECTORY_NUMBER 32

@implementation Joy_NetCacheTool

-(id) initWithPath:(NSString*)folderPath overtime:(NSTimeInterval)interval
{
	if ((self = [super init]))
	{
		_cacheFolderPath = [folderPath copy];
		_overtime = interval;
		
		[self checkCacheDirectories];
		
		// 清除过期的缓存数据
		if (interval > 0)
		{
			[NSThread detachNewThreadSelector:@selector(removeOvertimeCache) toTarget:self withObject:nil];
		}
	}
	return self;
}

-(void) checkCacheDirectories
{
	NSFileManager* fm = [NSFileManager defaultManager];
	
	// if root directory doesn't exist, or it's not a directory, create.
	BOOL isDirectory = YES;
	BOOL exists = [fm fileExistsAtPath:_cacheFolderPath isDirectory:&isDirectory];
	if (exists && !isDirectory)
	{
		[fm removeItemAtPath:_cacheFolderPath error:NULL];
		exists = NO;
	}
	if (!exists)
	{
		[fm createDirectoryAtPath:_cacheFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	for (NSInteger i = 0; i < DIRECTORY_NUMBER; ++i)
	{
		NSString* subPath = [_cacheFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"__%zi__", i]];
		isDirectory = YES;
		exists = [fm fileExistsAtPath:subPath isDirectory:&isDirectory];
		if (exists && !isDirectory)
		{
			[fm removeItemAtPath:subPath error:NULL];
			exists = NO;
		}
		if (!exists)
		{
			[fm createDirectoryAtPath:subPath withIntermediateDirectories:YES attributes:nil error:NULL];
		}
	}
}

-(NSString*) fullPathForKey:(NSString*)key
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//    //获取完整路径
//
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:key];//这里就是你将要存储的沙盒路径（.plist文件，名字自定义）
//
////    NSLog(@"%@",plistPath);
    
    //这里就是你将要存储的沙盒路径（.plist文件，名字自定义）
	NSString* dir = [_cacheFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"__%zi__", ([key hash] % DIRECTORY_NUMBER)]];
	return [dir stringByAppendingPathComponent:[self MD5StringWithStr:key]];
}

-(BOOL) hasCacheForKey:(NSString*)key
{
	if (key.length <= 0)
		return NO;
	
	NSString* path = [self fullPathForKey:key];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

-(void) clearCache
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:_cacheFolderPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:_cacheFolderPath error:NULL];
	}
	[self checkCacheDirectories];
}

-(void) removeOvertimeCache
{
	@autoreleasepool {
		int count = 0;
		NSFileManager* fm = [NSFileManager defaultManager];
		NSArray* dirs = [fm contentsOfDirectoryAtPath:_cacheFolderPath error:NULL];
		for (NSString* dirName in dirs)
		{
			NSString* subDir = [_cacheFolderPath stringByAppendingPathComponent:dirName];
			NSArray* files = [fm contentsOfDirectoryAtPath:subDir error:NULL];
			for (NSString* fileName in files)
			{
				NSString* path = [subDir stringByAppendingPathComponent:fileName];
				NSDictionary* attr = [fm attributesOfItemAtPath:path error:NULL];
				if (attr != nil && fabs([[attr fileModificationDate] timeIntervalSinceNow]) > _overtime)
				{
					[fm removeItemAtPath:path error:NULL];
					count++;
				}
			}
		}
		
		NSLog(@"Number of overtime cache data: %d", count);
	}
}

-(void) removeCacheForKey:(NSString*)key {
	if (key.length <= 0)
		return;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	}
}

-(NSString*)getString:(NSString*)key {
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		NSString *string = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:NULL];
		return string;
	}
	return nil;
}

-(void)saveString:(NSString*)key string:(NSString*)string {
	if (key.length <= 0)
		return;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	}
	if (string != nil)
        [string writeToFile:dataPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//		[string writeToFile:dataPath atomically:YES];   //  警告处理
}

-(NSData*)getData:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		return [NSData dataWithContentsOfFile:dataPath];
	}
	return nil;
}

-(void)saveData:(NSString*)key data:(NSData*)theData
{
	if (key.length <= 0)
		return;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	}
	if (theData != nil)
		[theData writeToFile:dataPath atomically:YES];
}

-(NSArray*)getArray:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
        
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        NSArray *dic = nil;
        if (data)
            dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return dic;
	}
	return nil;
}

-(void)saveArray:(NSString*)key array:(NSArray*)theArray
{
	if (key.length <= 0)
		return;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	}
    if (theArray != nil){
        NSData *data = [NSJSONSerialization dataWithJSONObject:theArray options:NSJSONWritingPrettyPrinted error:nil];
        BOOL suc = [data writeToFile:dataPath atomically:YES];
        if (!suc) {
            
        }
    }
}

-(NSDictionary*)getDictionary:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		
		NSData *data = [NSData dataWithContentsOfFile:dataPath];
		NSDictionary *dic = nil;
		if (data)
			dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
		return dic;
	}
	return nil;
}

-(void)saveDictionary:(NSString*)key dictionary:(NSDictionary*)theDictionary
{
	if (key.length <= 0)
		return;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	}
	if (theDictionary != nil) {
		NSData *data = [NSJSONSerialization dataWithJSONObject:theDictionary options:NSJSONWritingPrettyPrinted error:nil];
		BOOL suc = [data writeToFile:dataPath atomically:YES];
		if (!suc) {
            NSLog(@"writeToFile文件缓存失败");
        }else{
            NSLog(@"writeToFile文件缓存成功");
        }
	}
}


static Joy_NetCacheTool* _httpCache = nil;
static Joy_NetCacheTool* _defaultCache = nil;
static Joy_NetCacheTool* _permanenceCache = nil;

+(Joy_NetCacheTool*) cacheWithType:(DataCacheServiceType)cacheType
{
	switch (cacheType)
	{
		case DataCacheServiceHttp:
			if (_httpCache == nil)
			{
				@synchronized(self)
				{
					if (_httpCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
						NSString* httpPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"CacheRoot"];
						_httpCache = [[Joy_NetCacheTool alloc] initWithPath:httpPath overtime:0];
					}
				}
			}
			return _httpCache;
		case DataCacheServicePermanence:
			if (_permanenceCache == nil)
			{
				@synchronized(self)
				{
					if (_permanenceCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
						NSString* httpPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"__j4fvJ8H"];
						_permanenceCache = [[Joy_NetCacheTool alloc] initWithPath:httpPath overtime:0];
					}
				}
			}
			return _permanenceCache;
		default:
			if (_defaultCache == nil)
			{
				@synchronized(self)
				{
					if (_defaultCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
						NSString* defaultPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"ContentData"];
						_defaultCache = [[Joy_NetCacheTool alloc] initWithPath:defaultPath overtime:0];
					}
				}
			}
			return _defaultCache;
	}
	return nil;
}

#pragma mark 类方法扩展

+(void) scbuRemoveCacheForKey:(NSString*)key{
    [[Joy_NetCacheTool getDeafultCacheService] removeCacheForKey:key];
}

+(NSString*)scbuStringCacheForKey:(NSString*)key{
    NSString *cacheValue =  [[Joy_NetCacheTool getDeafultCacheService] getString:key];
    return cacheValue;
}

+(void)scbuCacheString:(NSString*)value forKey:(NSString*)key{
    [[Joy_NetCacheTool getDeafultCacheService] saveString:key string:value];
}

+(NSData*)scbuDataCacheForKey:(NSString*)key{
    NSData *data = [[Joy_NetCacheTool getDeafultCacheService] getData:key];
    return data;
}

+(void)scbuCacheData:(NSData *)data  forKey:(NSString*)key{
    [[Joy_NetCacheTool getDeafultCacheService] saveData:key data:data];
}

+(NSArray*)scbuArrayCacheForKey:(NSString*)key{
    NSArray *array = [[Joy_NetCacheTool getDeafultCacheService] getArray:key];
    return array;
}

+(void)scbuCacheArray:(NSArray*)array forKey:(NSString*)key{
    [[Joy_NetCacheTool getDeafultCacheService] saveArray:key array:array];
}

+(NSDictionary*)scbuDictCacheForKey:(NSString*)key{
    NSDictionary *dict = [[Joy_NetCacheTool getDeafultCacheService] getDictionary:key];
    return dict;
}

+(void)scbuCacheDict:(NSDictionary*)dict forKey:(NSString*)key{
    [[Joy_NetCacheTool getDeafultCacheService] saveDictionary:key dictionary:dict];
}

+(Joy_NetCacheTool *)getDeafultCacheService{
    Joy_NetCacheTool *cacheService = [Joy_NetCacheTool cacheWithType:DataCacheServiceDefault];
    return cacheService;
}

- (NSString *)MD5StringWithStr:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
