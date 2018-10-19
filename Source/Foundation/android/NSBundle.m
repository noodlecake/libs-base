/****************************************************************************
Copyright (c) Noodlecake Studios Inc
All Rights Reserved.

http://www.noodlecake.com

NOTICE:  All code written by Noodlecake Studios Inc
remain the property of Noodlecake Studios Inc.

****************************************************************************/
#import <Foundation/Foundation.h>

#if defined(ANDROID)
#import "AndroidJNIHelper.h"
#endif

NSString *GSPrivateExecutablePath() {
    return @"";
}

@interface NSBundle() {
	NSMutableDictionary* _defaultLocalizedStringsDict;
}

@end


static NSBundle* _mainBundle = nil;

@implementation NSBundle

+ (NSBundle *)mainBundle
{
    if (!_mainBundle)
        _mainBundle = [[NSBundle alloc] init];
    return _mainBundle;
}

+ (NSBundle*) bundleForClass: (Class)aClass
{
    // NOTIMPLEMENTED
    return [self mainBundle];
}

+ (NSBundle *) bundleForLibrary: (NSString *)libraryName
{
return [self bundleForLibrary: libraryName  version: nil];
}

+ (NSBundle *) bundleForLibrary: (NSString *)libraryName
        version: (NSString *)interfaceVersion
{
    return [self mainBundle];
}

- (NSDictionary *) infoDictionary
{
    if (_infoDict)
        return _infoDict;

    NSString* path = [self pathForResource: @"Info" ofType: @"plist"];

    if (path)
    {
        _infoDict = [[NSDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
        _infoDict = RETAIN([NSDictionary dictionary]);
    }
    return _infoDict;
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [[self infoDictionary] objectForKey:key]; // TODO: localize?
}

- (NSString*) pathForResource: (NSString*)name ofType: (NSString*)ext inDirectory: (NSString*)subPath
{
    if (subPath == nil)
        subPath = @"";
    return [self pathForResource:[[subPath stringByAppendingString:@"/"] stringByAppendingString:name] ofType:ext];
}

- (NSString*) pathForResource: (NSString*)name ofType: (NSString*)ext
{
	// For non-strings, just search root.
	// For strings, search locale first, then root, followed by English as a fallback.
	//
	NSMutableArray* searchPaths = [NSMutableArray array];
	if (!ext || ![ext isEqualToString:@"strings"]) {
		[searchPaths addObject:@""];
	} else {
		[searchPaths addObject:[NSString stringWithFormat:@"%@.lproj", [self currentLanguage]]];
		[searchPaths addObject:@""];
		[searchPaths addObject:@"en.lproj"];
	}

	for(NSString* searchPathExtension in searchPaths) {
		NSString* resourcePath =[self resourcePath];
		resourcePath = [resourcePath stringByAppendingPathComponent:searchPathExtension];
	
		// testing something
		NSArray* nameComponents = [name componentsSeparatedByString:@"/"];
		NSEnumerator *enumerator = [nameComponents reverseObjectEnumerator];
		NSString* newName = nil;
		bool skipNext = NO;
		for (NSString* component in enumerator) {
			if (nil == newName) {
				newName = component;
				if (component != [nameComponents objectAtIndex:0]) {
					newName = [@"/" stringByAppendingString:newName];
				}
				continue;
			}
			if ([component isEqualToString:@".."]) {
				skipNext = YES;
				continue;
			}
			if (skipNext) {
				skipNext = NO;
			} else {
				newName = [component stringByAppendingString:newName];
				if (component != [nameComponents objectAtIndex:0]) {
					newName = [@"/" stringByAppendingString:newName];
				}
			}
		}
		name = newName;
		//
	
		NSString *result = [ext length] > 0 ? [[name stringByAppendingString:@"."] stringByAppendingString:ext] : name;
		NSString* finalPath = [NSString stringWithFormat:@"%@/%@", resourcePath, result];
	
		finalPath = [finalPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
	
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
		
		//NSLog(@"NSBundle::pathForResource %@ -- %@ (%u)", name, finalPath, exists);
		if(exists) {
			return finalPath;
		}
	}
	
	return nil;
}

- (NSString*) resourcePath
{
#if defined(ANDROID)

	NSString* bundlePath = [self bundlePath];
	if(bundlePath) {
		return [bundlePath stringByAppendingString:@"/assets"];
	}

	return nil;
#else
    return @"/";
#endif
}

- (void) onLanguageChanged {
	// Flush the localized strings cache
	if(_defaultLocalizedStringsDict)
		[_defaultLocalizedStringsDict release];
	_defaultLocalizedStringsDict = nil;
}

- (NSString*) systemLanguage {
#if defined(ANDROID)

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
				 withClassName:"gnustep/foundation/Common"
					withMethodName:"getDefaultLanguageString"
					withParamCode:"()Ljava/lang/String;"])
	{

		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env,str);
		return ret;
	}

	return @"en";

#else
	return @"en";
#endif
}

- (NSString *) bundleIdentifier {
	return @"com.noodlecake.ssg4";
}

- (NSString*) currentLanguage {
	// Try to load an app specific language setting if available.  Otherwise, fallback to the system language.
	//
	NSString* appLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:@"appLanguage"];

	if (appLanguage) {
		return appLanguage;
	} else {
		return [self systemLanguage];
	}
}

- (NSString*) currentCountry {
#if defined(ANDROID)

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
				 withClassName:"gnustep/foundation/Common"
					withMethodName:"getDefaultCountryString"
					withParamCode:"()Ljava/lang/String;"])
	{

		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env,str);
		return ret;
	}

	return @"US";

#else
	return @"US";
#endif
}

- (NSString*) bundlePath
{
#if defined(ANDROID)

	JniMethodInfo t;

	if ([AndroidJniHelper getStaticMethodInfo:&t
				 withClassName:"gnustep/foundation/Common"
					withMethodName:"getPackageDir"
					withParamCode:"()Ljava/lang/String;"])
	{

		jstring str = (jstring)(*(t.env))->CallStaticObjectMethod(t.env, t.classID, t.methodID);

		NSString *ret = [AndroidJniHelper stringFromJstring:str];

		(*(t.env))->DeleteLocalRef(t.env, t.classID);
		(*(t.env))->DeleteLocalRef(t.env,str);
		return ret;
	}

	return nil;

#else
	return @"";
#endif
}

- (NSString*) localizedStringForKey: (NSString*)key value: (NSString*)value table: (NSString*)table
{
  // Cocotron implementation
  NSString     *result;
  NSString     *path;
  NSString     *contents=nil;
  NSDictionary *dictionary=nil;
  BOOL defaultTable = NO;

  if ([table length] == 0) {
    table = @"Localizable";
    defaultTable = YES;
  }

  if (defaultTable == YES && _defaultLocalizedStringsDict != nil) {
    dictionary = _defaultLocalizedStringsDict;
  } else {
    if ((path = [self pathForResource:table ofType:@"strings"]) != nil) {
      NSError* error;
      if ((contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error]) != nil) {
        dictionary = [contents propertyListFromStringsFileFormat];
        
        // BDG: Cache localized strings dictionary to improve performance.
        if (defaultTable == YES && _defaultLocalizedStringsDict == nil && dictionary != nil) {
          _defaultLocalizedStringsDict = [dictionary retain];
        }
      }
    }
  }

  if ((result = [dictionary objectForKey:key]) == nil)
    result = (value != nil && [value length] > 0) ? value : key;

  result = (result == nil) ? @"" : result;

  return result;
}

@end


































