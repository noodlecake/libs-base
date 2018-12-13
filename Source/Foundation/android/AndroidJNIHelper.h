/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

****************************************************************************/
#import <jni.h>
#import <Foundation/NSObject.h>

typedef struct JniMethodInfo_ {
	JNIEnv *    env;
	jclass      classID;
	jmethodID   methodID;
} JniMethodInfo;

@interface AndroidJniHelper : NSObject {

}

+(JNIEnv*) getEnv;
+(JavaVM*) getJavaVM;
+(jobject) getActivity;
+(void) setJavaVM:(JavaVM *)javaVM;
+(jclass) getClassID:(const char *)className withEnv:(JNIEnv *)env;
+(BOOL) getStaticMethodInfo:(JniMethodInfo*)methodinfo withClassName:(const char *)className withMethodName:(const char *)methodName withParamCode:(const char *)paramCode;
+(BOOL) getMethodInfo:(JniMethodInfo*)methodinfo withClassName:(const char *)className withMethodName:(const char *)methodName withParamCode:(const char *)paramCode;
+(NSString*) stringFromJstring:(jstring)str;

@end
