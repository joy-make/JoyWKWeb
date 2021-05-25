//
//  DataCacheService.h
//
//  Created by CaoQuan on 16/6/15.
//  Copyright © 2016年 CaoQuan. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum
{
	DataCacheServiceDefault = 0,
	DataCacheServiceHttp,
	DataCacheServicePermanence,
}
DataCacheServiceType;

@interface Joy_NetCacheTool : NSObject
{
//	NSString* _cacheFolderPath;
	NSTimeInterval _overtime;
}
@property (nonatomic, readonly) NSString* cacheFolderPath;

-(id) initWithPath:(NSString*)folderPath overtime:(NSTimeInterval)interval;
-(void) checkCacheDirectories;
-(BOOL) hasCacheForKey:(NSString*)key;
-(void) clearCache;
-(void) removeOvertimeCache;
-(void) removeCacheForKey:(NSString*)key;

-(NSString*)getString:(NSString*)key;
-(void)saveString:(NSString*)key string:(NSString*)string;
-(NSData*)getData:(NSString*)key;
-(void)saveData:(NSString*)key data:(NSData*)theData;
-(NSArray*)getArray:(NSString*)key;
-(void)saveArray:(NSString*)key array:(NSArray*)theArray;

-(NSDictionary*)getDictionary:(NSString*)key;
-(void)saveDictionary:(NSString*)key dictionary:(NSDictionary*)theDictionary;

+(Joy_NetCacheTool*) cacheWithType:(DataCacheServiceType)cacheType;

#pragma mark 类方法扩展--wanggp@sqbj.com-----------------------
+(void) scbuRemoveCacheForKey:(NSString*)key;

+(NSString*)scbuStringCacheForKey:(NSString*)key;

+(void)scbuCacheString:(NSString*)value forKey:(NSString*)key;

+(NSData*)scbuDataCacheForKey:(NSString*)key;

+(void)scbuCacheData:(NSData *)data forKey:(NSString*)key;

+(NSArray*)scbuArrayCacheForKey:(NSString*)key;

+(void)scbuCacheArray:(NSArray*)array forKey:(NSString*)key;

+(NSDictionary*)scbuDictCacheForKey:(NSString*)key;

+(void)scbuCacheDict:(NSDictionary*)dict forKey:(NSString*)key;

@end
