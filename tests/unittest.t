#charset "us-ascii"
#include <tads.h>

class UnitTest: object
    skip = nil
    only = nil
    run() {
        throw new Exception('Test missing implementation');
    }
;

function assertEquals(expectedValue, receivedValue) {
    if(expectedValue != receivedValue) {
        "\bassertEquals failed. \nReceived value: \n[<<receivedValue>>]\b differs from expected value: \n[<<expectedValue>>]\b";
        throw new Exception('assertEquals failed. Received value (<<receivedValue>>) differs from expected value (<<expectedValue>>)\n');
    }
}

testRunner: InitObject
    divider() {
        "<<repeatChar('=', 64)>>\n";
    }

    currentTest = nil
    succeeded = 0
    failed = 0

    execute() {
        try {
            divider();
            "Test runner starting: \n";
            local testCollection = [];
            
            forEachInstance(UnitTest, {x:testCollection += x });
            /*testCollection = testCollection.subset({x: !x.skip});
            local onlyOneTest = testCollection.subset({x:x.only==true});
            if(onlyOneTest) {
                onlyOneTest.forEach({x: runTest(x)});
            } else {*/
                testCollection.forEach({x: runTest(x)});
            //}
        } catch(Exception e) {
            failed++;
            "<<currentTest>>: *** FAILED! ***\n";
            "[<<e>>: <<e.exceptionMessage>>]\n";
        } finally {
            divider();
            "All tests have run: \n";
            "failed: <<failed>>\n";
            "succeeded: <<succeeded>>\n";
            divider();
        }
    }
    runTest(test) {
        currentTest = test;
        currentTest.run();
        succeeded++;
        "<<currentTest>>: ** TEST SUCCEEDED! **\n";
    }
;
