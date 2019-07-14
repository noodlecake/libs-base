/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

****************************************************************************/
/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/


#include "AndroidJniHelper.h"
#include <android/log.h>
#include <Foundation/NSString.h>
#include <android/asset_manager_jni.h>

#if 1
#define  LOG_TAG    "AndroidJniHelper"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOGD(...)
#endif

#define JAVAVM	[AndroidJniHelper getJavaVM]

static JavaVM *m_psJavaVM = NULL;

static AAssetManager* m_assetMgr = NULL;

    //////////////////////////////////////////////////////////////////////////
    // java vm helper function
    //////////////////////////////////////////////////////////////////////////

    jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    	m_psJavaVM = vm;
        return JNI_VERSION_1_4;
    }

	static BOOL getEnv(JNIEnv **env) {
		BOOL bRet = NO;

		do {
			if ((*m_psJavaVM)->GetEnv(m_psJavaVM, (void**)env, JNI_VERSION_1_4) != JNI_OK) {
				LOGD("Failed to get the environment using GetEnv()");
				break;
			}

			if ((*m_psJavaVM)->AttachCurrentThread(m_psJavaVM, env, 0) < 0) {
				LOGD("Failed to get the environment using AttachCurrentThread()");
				break;
			}

			bRet = YES;
		} while (0);

		return bRet;
	}

	static jclass getClassID_(const char *className, JNIEnv *env) {
		JNIEnv *pEnv = env;
		jclass ret = 0;

		do {
			if (! pEnv) {
				if (! getEnv(&pEnv)) {
					break;
				}
			}

			ret = (*pEnv)->FindClass(pEnv,className);
			if (! ret) {
				 LOGD("Failed to find class of %s", className);
				break;
			}
		} while (0);

		return ret;
	}

	static BOOL getStaticMethodInfo_(JniMethodInfo* methodinfo, const char *className, const char *methodName, const char *paramCode) {
		jmethodID methodID = 0;
		JNIEnv *pEnv = 0;
		BOOL bRet = NO;

        do {
			if (! getEnv(&pEnv)) {
				break;
			}

            jclass classID = getClassID_(className, pEnv);

            methodID = (*pEnv)->GetStaticMethodID(pEnv,classID, methodName, paramCode);
            if (! methodID) {
                LOGD("Failed to find static method id of %s", methodName);
                break;
            }

			methodinfo->classID = classID;
			methodinfo->env = pEnv;
			methodinfo->methodID = methodID;

			bRet = YES;
        } while (0);

        return bRet;
    }

	static BOOL getMethodInfo_(JniMethodInfo* methodinfo, const char *className, const char *methodName, const char *paramCode) {
		jmethodID methodID = 0;
		JNIEnv *pEnv = 0;
		BOOL bRet = NO;

		do {
			if (! getEnv(&pEnv)) {
				break;
			}

			jclass classID = getClassID_(className, pEnv);

			methodID = (*pEnv)->GetMethodID(pEnv,classID, methodName, paramCode);
			if (! methodID) {
				LOGD("Failed to find method id of %s", methodName);
				break;
			}

			methodinfo->classID = classID;
			methodinfo->env = pEnv;
			methodinfo->methodID = methodID;

			bRet = YES;
		} while (0);

		return bRet;
	}

	static NSString* jstring2string_(jstring jstr) {
		JNIEnv *env = 0;

		jboolean isCopy;
		if (! getEnv(&env)) {
			return nil;
		}

		const char* chars = (*env)->GetStringUTFChars(env, jstr, &isCopy);
		NSString* ret = [NSString stringWithUTF8String:chars];
		//if (isCopy) {
			(*env)->ReleaseStringUTFChars(env, jstr, chars);
		//}

		return ret;
	}


@implementation AndroidJniHelper


+(JavaVM*) getJavaVM {
	return m_psJavaVM;
}

+(void) setJavaVM:(JavaVM *)javaVM {
	m_psJavaVM = javaVM;
}

+(jclass) getClassID:(const char *)className withEnv:(JNIEnv *)env {
	return getClassID_(className, env);
}

+(BOOL) getStaticMethodInfo:(JniMethodInfo*)methodinfo withClassName:(const char *)className withMethodName:(const char *)methodName withParamCode:(const char *)paramCode {
	return getStaticMethodInfo_(methodinfo, className, methodName, paramCode);
}

+(BOOL) getMethodInfo:(JniMethodInfo*)methodinfo withClassName:(const char *)className withMethodName:(const char *)methodName withParamCode:(const char *)paramCode {
	return getMethodInfo_(methodinfo, className, methodName, paramCode);
}

+(JNIEnv*) getEnv {
	JNIEnv* env = 0;
	if (! getEnv(&env)) {
		return 0;
	}
	return env;
}

+(jobject) getActivity {

	JniMethodInfo t;

	if ([self getStaticMethodInfo:&t
			withClassName:"org/cocos2dx/lib/Cocos2dxActivity"
	withMethodName:"getActivity"
	withParamCode:"()Landroid/app/Activity;"]) {

		jobject obj = (jobject) (*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);
		return obj;
	}

	return NULL;

}

+(NSString*) stringFromJstring:(jstring)str {
	return jstring2string_(str);
}

+(void)setAssetManager:(jobject)j_obj {
	m_assetMgr = AAssetManager_fromJava([self getEnv], j_obj);
}

+(AAssetManager*)getAssetManager {
	return m_assetMgr;
}
@end
