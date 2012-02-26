echo Testing Mac ECUnitTestsExample

base=`dirname $0`
common="$base/../Scripts"
source "$common/test-common.sh"

xcodebuild -workspace "ECUnitTestsExample.xcworkspace" -scheme "ECUnitTestsExample" -sdk "$testSDKMac" test | "$common/$testConvertOutput"
