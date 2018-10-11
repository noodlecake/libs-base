/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

****************************************************************************/
#import <Foundation/Foundation.h>

enum {
   NSUbiquitousKeyValueStoreServerChange,
   NSUbiquitousKeyValueStoreInitialSyncChange,
   NSUbiquitousKeyValueStoreQuotaViolationChange,
   NSUbiquitousKeyValueStoreAccountChange
};

extern NSString * NSUbiquitousKeyValueStoreChangeReasonKey;
extern NSString * NSUbiquitousKeyValueStoreChangedKeysKey;
extern NSString * NSUbiquitousKeyValueStoreDidChangeExternallyNotification;

@interface NSUbiquitousKeyValueStore : NSObject {
  NSMutableDictionary* backingDict;
}

+ (NSUbiquitousKeyValueStore *)defaultStore;

- (NSArray *)arrayForKey:(NSString *)aKey;
- (BOOL)boolForKey:(NSString *)aKey;
- (NSData *)dataForKey:(NSString *)aKey;
- (NSDictionary *)dictionaryForKey:(NSString *)aKey;
- (NSDictionary *)dictionaryRepresentation;
- (double)doubleForKey:(NSString *)aKey;
- (long long)longLongForKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey;

- (void)removeObjectForKey:(NSString *)aKey;

- (void)setArray:(NSArray *)anArray forKey:(NSString *)aKey;
- (void)setBool:(BOOL)value forKey:(NSString *)aKey;
- (void)setData:(NSData *)aData forKey:(NSString *)aKey;
- (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey;
- (void)setDouble:(double)value forKey:(NSString *)aKey;
- (void)setLongLong:(long long)value forKey:(NSString *)aKey;
- (void)setObject:(id)anObject forKey:(NSString *)aKey;
- (void)setString:(NSString *)aString forKey:(NSString *)aKey;
- (NSString *)stringForKey:(NSString *)aKey;

- (BOOL)synchronize;

@end

