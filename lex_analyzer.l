%{
#include <stdio.h>
#include <string.h>
int yylineno;
%}

/* Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+([Ee][+-]?{DIGIT}+)?
CHAR        '(\\.|[^\\'])'
STRING      \"(\\.|[^\\"\n])*\"
COMMENT     "//".*
MCOMMENT    "/*"([^*]|"*"+[^*/])*"*"+"/"
%%

    /******** KEYWORDS ******/
"auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while" {
    printf("KEYWORD: %s at line : %d\n", yytext,yylineno++);
}

{ID}        { printf("IDENTIFIER: %s at line : %d\n", yytext,yylineno++); }
{INTEGER}   { printf("INTEGER: %s at line : %d\n", yytext,yylineno++); }
{FLOAT}     { printf("FLOAT: %s at line : %d\n", yytext,yylineno++); }
{CHAR}      { printf("CHAR: %s at line : %d\n", yytext,yylineno++); }
{STRING}    { printf("STRING: %s at line : %d\n", yytext,yylineno++); }

    /******** OPERATORS ******/
"+"|"-"|"*"|"/"|"%"|"++"|"--"|"=="|"!="|">"|"<"|">="|"<="|"&&"|"||"|"!"|"&"|"|"|"^"|"~"|"<<"|">>" {
    printf("OPERATOR: %s at line : %d\n", yytext,yylineno++);
}

    /******** ASSIGNMENT ******/
"="|"+="|"-="|"*="|"/="|"%="|"<<="|">>="|"&="|"^="|"|=" {
    printf("ASSIGNMENT: %s at line : %d\n", yytext,yylineno++);
}

    /******** PUNCTUATORS ******/
"("|")"|"{"|"}"|"["|"]"|";"|","|"."|"->" {
    printf("PUNCTUATOR: %s at line : %d\n", yytext,yylineno++);
}

{COMMENT}   { printf("COMMENT at line : %d\n",yylineno++); }
{MCOMMENT}  { printf("MULTILINE COMMENT at line : %d\n",yylineno++); }

[ \t\v\n\f] ;
. ;

%%

int yywrap() {
    return 1;
}

int main() {
    yyin = fopen("source.c","r");
    yylex();

    fclose(yyin);
    return 0;
}