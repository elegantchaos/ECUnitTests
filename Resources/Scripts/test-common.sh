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
mkdir -p "$build/test-reports"

testout="$build/out.log"
testerr="$build/err.log"

#if [[ "$testMac" == "" ]]; then
#    testMac=true
#fi

#if [[ "$testIOS" == "" ]]; then
#    testIOS=true
#if

config="Debug"

report()
{
#    pushd "$build" > /dev/null
    "$ocunit2junit" < "$testout" > /dev/null
    mv test-reports/* "$build/test-reports/" > /dev/null
    rmdir test-reports
#    popd > /dev/null
}

commonbuild()
{
    echo "Building $1 for $3"
    xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 -config "$config" $2 OBJROOT="$obj" SYMROOT="$sym" > "$testout" 2> "$testerr"
    result=$?
    if [[ $result != 0 ]]; then
        cat "$testerr"
        echo
        echo "** BUILD FAILURES **"
        echo "Build failed for scheme $1"
        exit $result
    fi

    report

    failures=`grep failed "$testout"`
    if [[ $failures != "" ]]; then
        echo $failures
        echo
        echo "** UNIT TEST FAILURES **"
        echo "Tests failed for scheme $1"
        exit $result
    fi

}

macbuild()
{
    if $testMac ; then

        commonbuild "$1" "$2" "macosx"

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

        commonbuild "$1" "$action" "iphonesimulator" "-arch i386"

    fi
}

