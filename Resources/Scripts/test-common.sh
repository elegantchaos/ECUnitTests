#!/usr/bin/env bash

# Common code for test scripts

if [[ $project == "" ]];
then
    echo "Need to define project variable."
    exit 1
fi

echo "Setting up tests for $project"


sym="/tmp/${project}tests"
obj="$sym/obj"

rm -rf "test-reports"
rm -rf "$sym"
mkdir -p "$sym"

testout="$sym/test.log"

testMac=true
testIOS=true

config="Release"

status=0

macbuild()
{
    if $testMac ; then

        echo "Building mac scheme $1"
        xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "macosx" -config "$config" $2 >> "$testout" 2>&1
        result=$?
        if [[ $result != 0 ]]; then
            echo "Build failed for scheme $1"
            status=$result
        fi

    fi
}

iosbuild()
{
    if $testIOS; then

        if [[ $2 == "test" ]];
        then
            action=build TEST_AFTER_BUILD=YES
        else
            action=$2
        fi

        echo "Building iOS scheme $1"
        xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "iphonesimulator" -arch i386 -config "$config" $action >> "$testout" 2>&1
        result=$?
        if [[ $result != 0 ]]; then
            echo "Build failed for scheme $1"
            status=$result
        fi

    fi
}

report()
{
    echo "Reporting test results"
    cp "$testout" .
    "$base/ocunit2junit/ocunit2junit.rb" < "$testout"

    rm -rf "$sym"
}
