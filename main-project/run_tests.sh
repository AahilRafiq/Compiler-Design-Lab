lex lex_code.l
yacc -d yacc_code.y

gcc lex.yy.c y.tab.c lib/table.c

# Run the tests

echo "Running test1.c"
echo "----------------------------------------------------"
./a.out < tests/test1.c

echo "Running test2.c"
echo "----------------------------------------------------"
./a.out < tests/test2.c

echo "Running test3.c"
echo "----------------------------------------------------"
./a.out < tests/test3.c

echo "Running test4.c"
echo "----------------------------------------------------"
./a.out < tests/test4.c

echo "Running test5.c"
echo "----------------------------------------------------"
./a.out < tests/test5.c