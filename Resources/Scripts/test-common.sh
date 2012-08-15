#!/usr/bin/env bash

# Common code for test scripts

if [[ $project == "" ]];
then
    echo "Need to define project variable."
    exit 1
fi

echo "Setting up tests for $project"

pushd "$base/.." > /dev/null
build="$PWD/test-build"
ocunit2junit="$PWD/ECUnitTests/Resources/Scripts/ocunit2junit/ocunit2junit.rb"
popd > /dev/null

sym="$build/sym"
obj="$build/obj"

rm -rf "$build"
mkdir -p "$build"

testout="$build/test.log"

testMac=true
testIOS=true

config="Debug"

status=0

macbuild()
{
    if $testMac ; then

        echo "Building mac scheme $1"
        xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "macosx" -config "$config" $2 OBJROOT="$obj" SYMROOT="$sym" >> "$testout" 2>&1
        result=$?
        if [[ $result != 0 ]]; then
            cat "$testout"
            echo "Build failed for scheme $1"
            exit $result
        fi

    fi
}

iosbuild()
{
    if $testIOS; then

        if [[ $2 == "test" ]];
        then
            action="build TEST_AFTER_BUILD=YES"
        else
            action=$2
        fi

        echo "Building iOS scheme $1"
        xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "iphonesimulator" -arch i386 -config "$config" OBJROOT="$obj" SYMROOT="$sym" $action >> "$testout" 2>&1
        result=$?
        if [[ $result != 0 ]]; then
            cat "$testout"
            echo "Build failed for scheme $1"
            exit $result
        fi

    fi
}

report()
{
    echo "Reporting test results"
    pushd "$build" > /dev/null
    "$ocunit2junit" < "$testout"
    popd > /dev/null
}
