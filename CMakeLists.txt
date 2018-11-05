#
# Copyright (c) 2011 Marius Zwicker <marius@mlba-team.de>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

cmake_minimum_required(VERSION 2.8)
INCLUDE (CheckIncludeFiles)

project(foundation)

set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fblocks -D__BLOCKS__ -fobjc-runtime=gnustep-1.9 \
-Wno-implicit-function-declaration \
-DGNUSTEP -DNS_BLOCKS_AVAILABLE -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 \
-DGSWARN -DGSDIAGNOSE \
")


file(GLOB SRC
		Source/Additions/GSTypeEncoding.c
		Source/Additions/GSObjCRuntime.m
		Source/Additions/GCObject.m
		Source/Additions/GCArray.m
		Source/Additions/GCDictionary.m
		Source/Additions/GSLock.m
		Source/Additions/GSMime.m
		Source/Additions/GSXML.m
		Source/Additions/GSFunctions.m
		Source/Additions/GSInsensitiveDictionary.m
		Source/Additions/NSArray+GNUstepBase.m
		Source/Additions/NSAttributedString+GNUstepBase.m
		Source/Additions/NSBundle+GNUstepBase.m
		Source/Additions/NSCalendarDate+GNUstepBase.m
		Source/Additions/NSData+GNUstepBase.m
		Source/Additions/NSDebug+GNUstepBase.m
		Source/Additions/NSError+GNUstepBase.m
		Source/Additions/NSHashTable+GNUstepBase.m
		Source/Additions/NSFileHandle+GNUstepBase.m
		Source/Additions/NSLock+GNUstepBase.m
		Source/Additions/NSMutableString+GNUstepBase.m
		Source/Additions/NSNumber+GNUstepBase.m
		Source/Additions/NSObject+GNUstepBase.m
		Source/Additions/NSPropertyList+GNUstepBase.m
		Source/Additions/NSProcessInfo+GNUstepBase.m
		Source/Additions/NSStream+GNUstepBase.m
		Source/Additions/NSString+GNUstepBase.m
		Source/Additions/NSTask+GNUstepBase.m
		Source/Additions/NSThread+GNUstepBase.m
		Source/Additions/NSURL+GNUstepBase.m
		Source/Additions/Unicode.m

		# ? blocks???
		Source/unix/GSRunLoopCtxt.m
		Source/unix/NSStream.m

		Source/GSLocale.m
		Source/preface.m
		Source/cifframe.m
		Source/CXXException.m
		Source/GSArray.m
		Source/GSAttributedString.m
		Source/GSBlocks.m
		Source/GSConcreteValue.m
		Source/GSCountedSet.m
		Source/GSDictionary.m
		Source/GSFTPURLHandle.m
		Source/GSFormat.m
		Source/GSHTTPAuthentication.m
		Source/GSHTTPURLHandle.m
		Source/GSICUString.m
		Source/GSPrivateHash.m
		Source/GSQuickSort.m
		Source/GSRunLoopWatcher.m
		Source/GSSet.m
		Source/GSShellSort.m
		Source/GSSocketStream.m
		Source/GSSet.m
		Source/GSShellSort.m
		Source/GSSocketStream.m
		Source/GSStream.m
		Source/GSString.m
		Source/GSTimSort.m
		Source/GSTLS.m
		Source/GSValue.m
		Source/GSSocksParser.m
		Source/GSSocksParserPrivate.m
		Source/GSSocks4Parser.m
		Source/GSSocks5Parser.m
		Source/NSAffineTransform.m
		Source/NSArchiver.m
		Source/NSArray.m
		Source/NSAssertionHandler.m
		Source/NSAttributedString.m
		Source/NSAutoreleasePool.m
		#Source/NSBundle.m
		Source/NSCache.m
		Source/NSCachedURLResponse.m
		Source/NSCalendar.m
		Source/NSCalendarDate.m
		Source/NSCallBacks.m
		Source/NSCharacterSet.m
		Source/NSClassDescription.m
		Source/NSCoder.m
		Source/NSCopyObject.m
		Source/NSCountedSet.m
		Source/NSConcreteHashTable.m
		Source/NSConcreteMapTable.m
		Source/NSConnection.m
		#Source/NSData.m
		Source/NSDate.m
		Source/NSDateFormatter.m
		Source/NSDebug.m
		Source/NSDecimal.m
		Source/NSDecimalNumber.m
		Source/NSDictionary.m
		Source/NSDistantObject.m
		Source/NSDistributedLock.m
		Source/NSDistributedNotificationCenter.m
		Source/NSEnumerator.m
		Source/NSError.m
		Source/NSException.m
		Source/NSFileCoordinator.m
		Source/NSFileHandle.m
		#Source/NSFileManager.m
		Source/NSFileVersion.m
		Source/NSFormatter.m
		Source/NSGarbageCollector.m
		Source/NSGeometry.m
		Source/NSHashTable.m
		Source/NSHost.m
		Source/NSHTTPCookie.m
		Source/NSHTTPCookieStorage.m
		Source/NSIndexPath.m
		Source/NSIndexSet.m
		Source/NSInvocation.m
		Source/NSInvocationOperation.m
		Source/NSJSONSerialization.m
		Source/NSKeyedArchiver.m
		Source/NSKeyedUnarchiver.m
		Source/NSKeyValueCoding.m
		Source/NSKeyValueObserving.m
		Source/NSLocale.m
		Source/NSLock.m
		Source/NSLog.m
		Source/NSMapTable.m
		Source/NSMetadata.m
		Source/NSMethodSignature.m
		Source/NSNotification.m
		Source/NSNotificationCenter.m
		Source/NSNotificationQueue.m
		Source/NSNull.m
		Source/NSNumber.m
		Source/NSNumberFormatter.m
		Source/NSObjCRuntime.m
		Source/NSObject.m
		Source/NSObject+NSComparisonMethods.m
		Source/NSOperation.m
		Source/NSPage.m
		Source/NSPipe.m
		Source/NSPointerArray.m
		Source/NSPointerFunctions.m
		Source/NSConcretePointerFunctions.m
		Source/NSPort.m
		Source/NSPortCoder.m
		Source/NSPortMessage.m
		Source/NSPortNameServer.m
		Source/NSPredicate.m
		Source/NSProcessInfo.m
		Source/NSPropertyList.m
		Source/NSProtocolChecker.m
		Source/NSProxy.m
		Source/NSRange.m
		Source/NSRegularExpression.m
		Source/NSRunLoop.m
		Source/NSScanner.m
		Source/NSSerializer.m
		Source/NSSet.m
		Source/NSSocketPort.m
		Source/NSSocketPortNameServer.m
		Source/NSSortDescriptor.m
		Source/NSSpellServer.m
		Source/NSString.m
		Source/NSTask.m
		Source/NSThread.m
		Source/NSTimer.m
		Source/NSTimeZone.m
		Source/NSUnarchiver.m
		Source/NSUndoManager.m
		Source/NSURL.m
		Source/NSURLSession.m
		Source/NSURLAuthenticationChallenge.m
		Source/NSURLCache.m
		Source/NSURLCredential.m
		Source/NSURLConnection.m
		Source/NSURLCredentialStorage.m
		Source/NSURLDownload.m
		Source/NSURLProtectionSpace.m
		Source/NSURLProtocol.m
		Source/NSURLRequest.m
		Source/NSURLResponse.m
		Source/NSTextCheckingResult.m
		Source/NSURLHandle.m
		Source/NSUserDefaults.m
		Source/NSUserNotification.m
		Source/NSUUID.m
		Source/NSValue.m
		Source/NSValueTransformer.m
		Source/NSXMLDocument.m
		Source/NSXMLDTD.m
		Source/NSXMLDTDNode.m
		Source/NSXMLElement.m
		Source/NSXMLNode.m
		Source/NSXMLParser.m
		Source/NSZone.m
		Source/externs.m
		Source/objc-load.m
		Source/GSFileHandle.m
		Source/NSMessagePort.m
		Source/NSMessagePortNameServer.m
		Source/GSFFIInvocation.m

		#android additions
		Source/Foundation/android/AndroidJNIHelper.m
		Source/Foundation/android/ioapi.m
		Source/Foundation/android/unzip.m
		Source/Foundation/android/NSPlatform.m
		Source/Foundation/android/NSBundle.m
		Source/Foundation/android/NSFileManager.m
		Source/Foundation/android/NSData.m
		Source/Foundation/android/NSPathUtilities.m
		)

source_group(src FILES ${SRC})

#includes
include_directories(
		${CMAKE_CURRENT_LIST_DIR}/../libobjc2
		${CMAKE_CURRENT_LIST_DIR}/../libffi/linux-arm
		${CMAKE_CURRENT_LIST_DIR}
		${CMAKE_CURRENT_LIST_DIR}/Headers
		${CMAKE_CURRENT_LIST_DIR}/Headers/Additions
		${CMAKE_CURRENT_LIST_DIR}/Source
		${CMAKE_CURRENT_LIST_DIR}/Source/android
)


message("-- building foundation as shared lib")
add_library(foundation STATIC ${SRC} ${INCL})

target_link_libraries(foundation ${log-lib} ${z-lib} objc ffi )
