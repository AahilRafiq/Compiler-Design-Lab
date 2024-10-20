lex lex_code.l
yacc -d yacc_code.y

gcc lex.yy.c y.tab.c lib/table.c
./a.out < tests/test2.c