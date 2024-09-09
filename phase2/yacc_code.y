%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *s);

%}

%union {
    int ival;
    char *sval;
}

%token <ival> NUMBER
%token <sval> IDENTIFIER STRING
%token INT CHAR FLOAT DOUBLE VOID
%token STRUCT UNION STATIC RETURN GOTO IF ELSE WHILE FOR DO BREAK CONTINUE SWITCH CASE DEFAULT
%token PLUS MINUS MUL DIV MOD ASSIGN EQ NE LT LE GT GE AND OR NOT
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COLON

%start program

%%

program:
    external_declaration_list
    ;

external_declaration_list:
    external_declaration
    | external_declaration_list external_declaration
    ;

external_declaration:
    function_definition
    | declaration
    ;

function_definition:
    type_specifier IDENTIFIER LPAREN parameter_list RPAREN compound_statement
    ;

parameter_list:
    parameter_declaration
    | parameter_list COMMA parameter_declaration
    | /* empty */
    ;

parameter_declaration:
    type_specifier IDENTIFIER
    ;

declaration:
    type_specifier declarator_list SEMICOLON
    ;

type_specifier:
    INT | CHAR | FLOAT | DOUBLE | VOID | STRUCT IDENTIFIER | UNION IDENTIFIER | STATIC
    ;

declarator_list:
    declarator
    | declarator_list COMMA declarator
    ;

declarator:
    IDENTIFIER
    | IDENTIFIER LBRACKET NUMBER RBRACKET
    ;

compound_statement:
    LBRACE declaration_list statement_list RBRACE
    ;

declaration_list:
    /* empty */
    | declaration_list declaration
    ;

statement_list:
    /* empty */
    | statement_list statement
    ;

statement:
    expression_statement
    | compound_statement
    | if_statement
    | while_statement
    | do_while_statement
    | for_statement
    | return_statement
    | goto_statement
    | labeled_statement
    | break_statement
    | continue_statement
    | switch_statement
    ;

expression_statement:
    expression SEMICOLON
    | SEMICOLON
    ;

if_statement:
    IF LPAREN expression RPAREN statement ELSE statement
    | IF LPAREN expression RPAREN statement
    ;

while_statement:
    WHILE LPAREN expression RPAREN statement
    ;

do_while_statement:
    DO statement WHILE LPAREN expression RPAREN SEMICOLON
    ;

for_statement:
    FOR LPAREN expression_statement expression_statement expression RPAREN statement
    ;

return_statement:
    RETURN expression SEMICOLON
    ;

goto_statement:
    GOTO IDENTIFIER SEMICOLON
    ;

labeled_statement:
    IDENTIFIER COLON statement
    ;

break_statement:
    BREAK SEMICOLON
    ;

continue_statement:
    CONTINUE SEMICOLON
    ;

switch_statement:
    SWITCH LPAREN expression RPAREN LBRACE case_list default_case RBRACE
    ;

case_list:
    case_statement
    | case_list case_statement
    ;

case_statement:
    CASE NUMBER COLON statement_list
    ;

default_case:
    DEFAULT COLON statement_list
    | /* empty */
    ;

expression:
    IDENTIFIER ASSIGN expression
    | expression PLUS expression
    | expression MINUS expression
    | expression MUL expression
    | expression DIV expression
    | expression MOD expression
    | LPAREN expression RPAREN
    | IDENTIFIER
    | NUMBER
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    return yyparse();
}
