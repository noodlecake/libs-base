/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

NOTICE:  All code written by Noodlecake Studios Inc
remain the property of Noodlecake Studios Inc.

****************************************************************************/
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "NSPlatform.h"
#import <Foundation/NSThread.h>
#import <Foundation/NSString.h>
//#import <Foundation/NSRaise.h>
//#import <Foundation/NSDebug.h>
#import <Foundation/NSArray.h>
// #import <Foundation/NSPipe.h>
#import <Foundation/NSDictionary.h>
// #import <Foundation/NSNotificationCenter.h>
//#import <Foundation/NSFileHandle.h>
//#import <Foundation/NSRunLoop.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>

#import "AndroidJNIHelper.h"
#include <android/log.h>

#if 1
#define  LOG_TAG    "NSPlatform"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOGD(...)
#endif


// extern NSString *NSPlatformClassName;
static NSPlatform *currentPlatform = nil;

@implementation NSPlatform

// +currentPlatform {
//    return NSThreadSharedInstance(NSPlatformClassName);
// }

+ (NSPlatform *) currentPlatform
{
    if (!currentPlatform) {
        currentPlatform = [[NSPlatform alloc] init];
    }
    return currentPlatform;
}

-(NSInputSource *)parentDeathInputSource {
   return nil;
}

-(Class)taskClass {
   assert(false);
   return Nil;
}

-(Class)pipeClass {
   assert(false);
   return Nil;
}

-(Class)lockClass {
   assert(false);
   return Nil;
}

-(Class)conditionLockClass {
   assert(false);
   return Nil;
}

-(Class)persistantDomainClass {
   assert(false);
   return Nil;
}

-(NSString *)userName {

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
	     	 	 withClassName:"gnustep/foundation/Common"
					withMethodName:"getPackageName"
					withParamCode:"()Ljava/lang/String;"])
	{
		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		//LOGD("userName %s", [ret UTF8String]);

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env, str);
		return ret;
	}

	return nil;
}

-(NSString *)fullUserName {
   assert(false);
   return nil;
}

-(NSString *)homeDirectory {

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
	     	 	 withClassName:"gnustep/foundation/Common"
					withMethodName:"getDocumentsDir"
					withParamCode:"()Ljava/lang/String;"])
	{
		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		//LOGD("homeDirectory %s", [ret UTF8String]);

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env, str);
		return ret;
	}

	return nil;
}

-(NSString *)temporaryDirectory {

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
	     	 	 withClassName:"gnustep/foundation/Common"
					withMethodName:"getTmpDir"
					withParamCode:"()Ljava/lang/String;"])
	{
		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		//LOGD("homeDirectory %s", [ret UTF8String]);

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env, str);
		return ret;
	}

	return nil;
}

-(NSArray *)arguments {
   assert(false);
   return nil;
}

-(NSDictionary *)environment {
   assert(false);
   return nil;
}

-(NSTimeZone *)systemTimeZone {
   assert(false);
   return nil;
}

-(NSString *)hostName {
   assert(false);
   return nil;
}

-(NSString *)DNSHostName {
   assert(false);
   return nil;
}

-(NSArray *)addressesForDNSHostName:(NSString *)name {
   assert(false);
   return nil;
}

-(void *)mapContentsOfFile:(NSString *)path length:(NSUInteger *)length {
   assert(false);
   return NULL;
}

-(void)unmapAddress:(void *)ptr length:(NSUInteger)length {
   assert(false);
}

-(BOOL)readContentsOfFile:(NSString *)path bytes:(const void **)bytes length:(NSUInteger*)length {
   assert(false);
   return NO;
}

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(NSUInteger)length atomically:(BOOL)atomically {
   assert(false);
   return NO;
}

-(void)checkEnvironmentKey:(NSString *)key value:(NSString *)value {
   // if([key isEqualToString:@"NSZombieEnabled"]){   
   //  if((NSZombieEnabled=[value isEqual:@"YES"]))
   //   NSCLog("NSZombieEnabled=YES");
   // }
}

-(void)startThread {
   //assert(false);
}

-(void)endThread {
   //assert(false);
}

-(Class)URLProtocolClass {
   assert(false);
   return Nil;
}

-(id)RunLoopCreate {
   assert(false);
   return Nil;
}

-(void*)RunLoopGetCurrent {
  assert(false);
  return NULL;
}

@end

