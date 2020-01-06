target_compile_definitions(
    mbgl-core
    PUBLIC MBGL_USE_GLES2 GLES_SILENCE_DEPRECATION
)

if(NOT DEFINED IOS_DEPLOYMENT_TARGET)
    set(IOS_DEPLOYMENT_TARGET "11.2")
endif()

set(CMAKE_OSX_ARCHITECTURES "arm64")

macro(initialize_ios_target target)
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${IOS_DEPLOYMENT_TARGET}")
    # set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_ENABLE_BITCODE "YES")
    # set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE bitcode)
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH $<$<CONFIG:Debug>:YES>)
endmacro()

set_target_properties(mbgl-core PROPERTIES XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)

target_sources(
    mbgl-core
    PRIVATE
        ${MBGL_ROOT}/platform/darwin/src/async_task.cpp
        ${MBGL_ROOT}/platform/darwin/src/collator.mm
        ${MBGL_ROOT}/platform/darwin/src/gl_functions.cpp
        ${MBGL_ROOT}/platform/darwin/src/headless_backend_eagl.mm
        ${MBGL_ROOT}/platform/darwin/src/native_apple_interface.m
        ${MBGL_ROOT}/platform/darwin/src/http_file_source.mm
        ${MBGL_ROOT}/platform/darwin/src/image.mm
        ${MBGL_ROOT}/platform/darwin/src/local_glyph_rasterizer.mm
        ${MBGL_ROOT}/platform/darwin/src/logging_nslog.mm
        ${MBGL_ROOT}/platform/darwin/src/nsthread.mm
        ${MBGL_ROOT}/platform/darwin/src/number_format.mm
        ${MBGL_ROOT}/platform/darwin/src/reachability.m
        ${MBGL_ROOT}/platform/darwin/src/run_loop.cpp
        ${MBGL_ROOT}/platform/darwin/src/string_nsstring.mm
        ${MBGL_ROOT}/platform/darwin/src/timer.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/gfx/headless_backend.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/gfx/headless_frontend.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/gl/headless_backend.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/map/map_snapshotter.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/asset_file_source.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/default_file_source.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/file_source.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/file_source_request.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/local_file_request.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/local_file_source.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/offline.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/offline_database.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/offline_download.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/online_file_source.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/storage/sqlite3.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/text/bidi.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/compression.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/monotonic_timer.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/png_writer.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/thread_local.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/utf.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/util/thread_local.cpp
        ${MBGL_ROOT}/platform/default/src/mbgl/layermanager/layer_manager.cpp
)

target_include_directories(
    mbgl-core
    PRIVATE ${MBGL_ROOT}/platform/darwin/include ${MBGL_ROOT}/platform/default/include
)

include(${PROJECT_SOURCE_DIR}/vendor/icu.cmake)

initialize_ios_target(mbgl-core)
initialize_ios_target(mbgl-vendor-icu)

target_link_libraries(
    mbgl-core
    PRIVATE
        "-framework CoreGraphics"
        "-framework CoreImage"
        "-framework CoreLocation"
        "-framework CoreServices"
        "-framework CoreText"
        "-framework Foundation"
        "-framework GLKit"
        "-framework ImageIO"
        "-framework OpenGLES"
        "-framework QuartzCore"
        "-framework Security"
        "-framework SystemConfiguration"
        "-framework UIKit"
        "-framework WebKit"
        mbgl-vendor-icu
        sqlite3
        z
)

enable_testing()
set(RESOURCES ${MBGL_ROOT}/render-test/ios/Main.storyboard ${MBGL_ROOT}/render-test/ios/LaunchScreen.storyboard ${MBGL_ROOT}/test-data)

add_executable(
    RenderTestApp
    ${MBGL_ROOT}/render-test/ios/ios_test_runner.hpp
    ${MBGL_ROOT}/render-test/ios/ios_test_runner.cpp
    ${MBGL_ROOT}/render-test/ios/AppDelegate.h
    ${MBGL_ROOT}/render-test/ios/AppDelegate.m
    ${MBGL_ROOT}/render-test/ios/ViewController.h
    ${MBGL_ROOT}/render-test/ios/ViewController.m
    ${MBGL_ROOT}/render-test/ios/iosTestRunner.h
    ${MBGL_ROOT}/render-test/ios/iosTestRunner.mm
    ${MBGL_ROOT}/render-test/ios/main.m
    ${RESOURCES}
)

initialize_ios_target(RenderTestApp)

set(MACOSX_BUNDLE_INFO_STRING "com.mapbox.RenderTestApp")
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.mapbox.RenderTestApp")
set(MACOSX_BUNDLE_BUNDLE_NAME "com.mapbox.RenderTestApp")
set(MACOSX_BUNDLE_BUNDLE_VERSION "1.0")
set(MACOSX_DEPLOYMENT_TARGET ${DEPLOYMENT_TARGET})

set_target_properties(
    RenderTestApp
    PROPERTIES
        MACOSX_BUNDLE
        TRUE
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY
        ""
        XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED
        "NO"
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
        ""
        MACOSX_BUNDLE_IDENTIFIER
        com.mapbox.RenderTestApp
        MACOSX_BUNDLE_INFO_PLIST
        ${MBGL_ROOT}/render-test/ios/Info.plist
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "GJZR2MEM28"
        RESOURCE
        "${RESOURCES}"
)

target_include_directories(
    RenderTestApp
    PUBLIC {MBGL_ROOT}/render-test/include ${MBGL_ROOT}/include
)

target_include_directories(
    RenderTestApp
    PRIVATE
        ${MBGL_ROOT}/platform/darwin/src
        ${MBGL_ROOT}/platform/darwin/include
        ${MBGL_ROOT}/platform/darwin/include/mbgl/interface/
        ${MBGL_ROOT}/platform/default/include
        ${MBGL_ROOT}/src
)

target_include_directories(
    RenderTestApp
    PUBLIC ${MBGL_ROOT}/render-test/ios
)

target_link_libraries(
    RenderTestApp
    PRIVATE
        "-framework CoreGraphics"
        "-framework CoreLocation"
        "-framework Foundation"
        "-framework OpenGLES"
        "-framework QuartzCore"
        "-framework UIKit"
        mbgl-render-test
)

macro (set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE)
    set_property (TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} ${XCODE_VALUE})
endmacro (set_xcode_property)

SET_XCODE_PROPERTY(RenderTestApp CODE_SIGN_IDENTITY $ENV{CODESIGNIDENTITY})
SET_XCODE_PROPERTY(RenderTestApp DEVELOPMENT_TEAM $ENV{IOS_DEVELOPMENT_TEAM})
SET_XCODE_PROPERTY(RenderTestApp PROVISIONING_PROFILE_SPECIFIER $ENV{PROVISIONING_PROFILE_NAME})

find_package(XCTest REQUIRED)

xctest_add_bundle(RenderTestAppTests RenderTestApp ${MBGL_ROOT}/render-test/ios/tests/Tests.m)

initialize_ios_target(RenderTestAppTests)

target_include_directories(
    RenderTestAppTests
    PUBLIC ${MBGL_ROOT}/render-test/ios
)

xctest_add_test(XCTest.RenderTestApp RenderTestAppTests)

set_target_properties(
    RenderTestAppTests
    PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST
        ${MBGL_ROOT}/render-test/ios/tests/Info.plist
        XCODE_ATTRIBUTE_USES_XCTRUNNER
        "YES"
        XCODE_ATTRIBUTE_TEST_TARGET_NAME
        "RenderTestApp"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "GJZR2MEM28"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY
        ""
        XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED
        "NO"
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
        ""
)
set_property(TARGET RenderTestAppTests PROPERTY XCODE_ATTRIBUTE_TEST_HOST)
set_property(TARGET RenderTestAppTests PROPERTY XCODE_ATTRIBUTE_BUNDLE_LOADER)

unset(IOS_DEPLOYMENT_TARGET CACHE)
