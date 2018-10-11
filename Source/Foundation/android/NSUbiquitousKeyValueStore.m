/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

****************************************************************************/

#import "NSUbiquitousKeyValueStore.h"
#import "Foundation/android/AndroidJniHelper.h"

NSString* NSUbiquitousKeyValueStoreChangeReasonKey = @"NSUbiquitousKeyValueStoreChangeReasonKey";
NSString* NSUbiquitousKeyValueStoreChangedKeysKey = @"NSUbiquitousKeyValueStoreChangedKeysKey";
NSString* NSUbiquitousKeyValueStoreDidChangeExternallyNotification = @"NSUbiquitousKeyValueStoreDidChangeExternallyNotificaiton";

@interface NSUbiquitousKeyValueStore (Refresh)
-(void) refreshWithDictionary:(NSMutableDictionary*)dict;
-(void) sendToCloud;
@end

@implementation NSUbiquitousKeyValueStore

static NSUbiquitousKeyValueStore *dStore = nil;

- (id)init {
  if ((self = [super init]) != nil) {
    backingDict = [NSMutableDictionary dictionaryWithCapacity:16];
    [backingDict retain];
  }

  return self;
}

+ (NSUbiquitousKeyValueStore *)defaultStore {
  if (dStore == nil) {
    dStore = [[NSUbiquitousKeyValueStore alloc] init];
  }

  return dStore;
}

- (NSArray *)arrayForKey:(NSString *)aKey {
  return [self objectForKey:aKey];
}

- (BOOL)boolForKey:(NSString *)aKey {
  return [[self objectForKey:aKey] boolValue];
}

- (NSData *)dataForKey:(NSString *)aKey {
  return [self objectForKey:aKey];
}

- (NSDictionary *)dictionaryForKey:(NSString *)aKey {
  return [self objectForKey:aKey];
}

- (NSDictionary *)dictionaryRepresentation {
  return backingDict;
}

- (double)doubleForKey:(NSString *)aKey {
  return [[self objectForKey:aKey] doubleValue];
}

- (long long)longLongForKey:(NSString *)aKey {
  return [[self objectForKey:aKey] longLongValue];
}

- (id)objectForKey:(NSString *)aKey {
  return [backingDict objectForKey:aKey];
}

- (void)removeObjectForKey:(NSString *)aKey {
  [backingDict removeObjectForKey:aKey];
  [self sendToCloud];
}

- (void)setArray:(NSArray *)anArray forKey:(NSString *)aKey {
  [self setObject:anArray forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(NSString *)aKey {
  [self setObject:[NSNumber numberWithBool:value] forKey:aKey];
}

- (void)setData:(NSData *)aData forKey:(NSString *)aKey {
  [self setObject:aData forKey:aKey];
}

- (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey {
  [self setObject:aDictionary forKey:aKey];
}

- (void)setDouble:(double)value forKey:(NSString *)aKey {
  [self setObject:[NSNumber numberWithDouble:value] forKey:aKey];
}

- (void)setLongLong:(long long)value forKey:(NSString *)aKey {
  [self setObject:[NSNumber numberWithLongLong:value] forKey:aKey];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
  NSLog(@"Setting %@ for key %@", anObject, aKey);
  [backingDict setObject:anObject forKey:aKey];
  [self sendToCloud];
}

- (void)setString:(NSString *)aString forKey:(NSString *)aKey {
  [self setObject:aString forKey:aKey];
}

- (NSString *)stringForKey:(NSString *)aKey {
  return [self objectForKey:aKey];
}

- (BOOL)synchronize {
  JniMethodInfo t;
  if ([AndroidJniHelper getStaticMethodInfo:&t
       withClassName:"com/noodlecake/flow/utils/CloudStorageHelper"
    withMethodName:"loadCloudData"
    withParamCode:"()V"]) {
        (*(t.env))->CallStaticVoidMethod(t.env, t.classID, t.methodID);
  }

  return YES;
}

-(void) refreshWithDictionary:(NSMutableDictionary*) dict {
  [backingDict release];
  backingDict = dict;
  [backingDict retain];

}

-(void) sendToCloud {
  JniMethodInfo info;
  int returnValue = -1;

  if (![AndroidJniHelper getStaticMethodInfo:&info
       withClassName:"com/noodlecake/flow/utils/CloudStorageHelper"
    withMethodName:"saveCloudData"
    withParamCode:"([B)V"]) {
    return;
  }

  NSData* data = [NSPropertyListSerialization dataFromPropertyList:backingDict format:NSPropertyListGNUstepBinaryFormat errorDescription:NULL];

  int size = [data length];
  jbyteArray dataArray = (*info.env)->NewByteArray(info.env, size);
  const void* nsDataBytes = [data bytes];
  (*info.env)->SetByteArrayRegion(info.env, dataArray, 0, size, nsDataBytes);

  (*(info.env))->CallStaticVoidMethod(info.env, info.classID, info.methodID, dataArray);
  return;
}

-(void) dealloc {
  [backingDict release];
  [super dealloc];
}

@end

jbyteArray Java_com_noodlecake_flow_utils_CloudStorageHelper_nativeResolveData(JNIEnv* env, jobject thiz, jbyteArray data) {
  GSRegisterCurrentThread();
  CREATE_AUTORELEASE_POOL(arp);

  NSLog(@"Java_com_noodlecake_flow_utils_CloudStorageHelper_nativeResolveData");
  jbyte* bufferPtr = (*env)->GetByteArrayElements(env, data, NULL);
  jsize lengthOfArray = (*env)->GetArrayLength(env, data);

  NSMutableDictionary* dict = nil;

  if (lengthOfArray > 0) {
    NSData* newData = [NSData dataWithBytes:bufferPtr length:lengthOfArray];
    (*env)->ReleaseByteArrayElements(env, data, bufferPtr, 0);
    dict = [NSPropertyListSerialization propertyListFromData:newData mutabilityOption:NSPropertyListMutableContainers format:NULL errorDescription:NULL];
  }

  if (dict == nil) {
    dict = [NSMutableDictionary dictionary];
  }

  [[NSUbiquitousKeyValueStore defaultStore] refreshWithDictionary:dict];
  [[NSNotificationCenter defaultCenter] postNotificationName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];

  RELEASE(arp);
  return NULL;
}

void Java_com_noodlecake_flow_utils_CloudStorageHelper_resendToCloud(JNIEnv* env, jobject thiz) {
  GSRegisterCurrentThread();
  CREATE_AUTORELEASE_POOL(arp);

  [[NSUbiquitousKeyValueStore defaultStore] sendToCloud];

  RELEASE(arp);
}

