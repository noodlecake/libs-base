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

#import <Foundation/NSPlatform.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSString.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSArray.h>
// #import <Foundation/NSPipe.h>
#import <Foundation/NSMutableDictionary.h>
// #import <Foundation/NSNotificationCenter.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSData.h>
// #import <Foundation/NSRaiseException.h>
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
   NSInvalidAbstractInvocation();
   return Nil;
}

-(Class)pipeClass {
   NSInvalidAbstractInvocation();
   return Nil;
}

-(Class)lockClass {
   NSInvalidAbstractInvocation();
   return Nil;
}

-(Class)conditionLockClass {
   NSInvalidAbstractInvocation();
   return Nil;
}

-(Class)persistantDomainClass {
   NSInvalidAbstractInvocation();
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
   NSInvalidAbstractInvocation();
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
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSDictionary *)environment {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSTimeZone *)systemTimeZone {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSString *)hostName {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSString *)DNSHostName {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSArray *)addressesForDNSHostName:(NSString *)name {
   NSInvalidAbstractInvocation();
   return nil;
}

-(void *)mapContentsOfFile:(NSString *)path length:(NSUInteger *)length {
   NSInvalidAbstractInvocation();
   return NULL;
}

-(void)unmapAddress:(void *)ptr length:(NSUInteger)length {
   NSInvalidAbstractInvocation();
}

-(BOOL)readContentsOfFile:(NSString *)path bytes:(const void **)bytes length:(NSUInteger*)length {
   NSInvalidAbstractInvocation();
   return NO;
}

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(NSUInteger)length atomically:(BOOL)atomically {
   NSInvalidAbstractInvocation();
   return NO;
}

-(void)checkEnvironmentKey:(NSString *)key value:(NSString *)value {
   // if([key isEqualToString:@"NSZombieEnabled"]){   
   //  if((NSZombieEnabled=[value isEqual:@"YES"]))
   //   NSCLog("NSZombieEnabled=YES");
   // }
}

-(void)startThread {
   //NSInvalidAbstractInvocation();
}

-(void)endThread {
   //NSInvalidAbstractInvocation();
}

-(Class)URLProtocolClass {
   NSInvalidAbstractInvocation();
   return Nil;
}

-(id)RunLoopCreate {
   NSInvalidAbstractInvocation();
   return Nil;
}

-(void*)RunLoopGetCurrent {
  NSInvalidAbstractInvocation();
  return NULL;
}

@end

