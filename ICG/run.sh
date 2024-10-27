#!/bin/bash

# Function to compile and run the tests
function run_tests() {
    flex scanner.l && yacc -d parser.y && gcc y.tab.c lex.yy.c -w
    local total_testcases="$1"
    echo "Running Test cases for ICG phase $total_testcases"
    local start=1
    while [ $start -le $total_testcases ]
    do
        printf "\n\n"
        for i in {1..40}
        do
            echo -ne "_"
        done
        echo -ne "Testcase number $start in progress"
        for i in {1..40}
        do
            echo -ne "_"
        done
        printf "\n\n"
        local filename="testfiles/test"$start".c"
        ./a.out $filename
        ((start++))
    done
}

# Get the number of test files in the testfiles directory
number_of_files=`ls -l ./testfiles/ | egrep -c '^-'`

# Run the tests
run_tests $number_of_files
