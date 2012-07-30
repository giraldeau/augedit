#!/bin/sh
make
lcov --directory . --zerocounters
ctest
lcov --directory . --capture --output-file app.info
genhtml -o lcov.out app.info

echo "report: lcov.out/index.html"
