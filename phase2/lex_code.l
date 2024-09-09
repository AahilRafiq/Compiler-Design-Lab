%{
#include "y.tab.h"
%}

%%
"int"               { return INT; }
"char"              { return CHAR; }
"float"             { return FLOAT; }
"double"            { return DOUBLE; }
"void"              { return VOID; }
"struct"            { return STRUCT; }
"union"             { return UNION; }
"static"            { return STATIC; }
"return"            { return RETURN; }
"goto"              { return GOTO; }
"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"for"               { return FOR; }
"do"                { return DO; }
"break"             { return BREAK; }
"continue"          { return CONTINUE; }
"switch"            { return SWITCH; }
"case"              { return CASE; }
"default"           { return DEFAULT; }

"="                 { return ASSIGN; }
"=="                { return EQ; }
"!="                { return NE; }
"<"                 { return LT; }
"<="                { return LE; }
">"                 { return GT; }
">="                { return GE; }

"&&"                { return AND; }
"||"                { return OR; }
"!"                 { return NOT; }

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"                 { return MOD; }

";"                 { return SEMICOLON; }
","                 { return COMMA; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }
":"                 { return COLON; }

[0-9]+              { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
\"[^\"\n]*\"        { yylval.sval = strdup(yytext); return STRING; }
[ \t\n\r]+          { /* ignore whitespace */ }

.                   { printf("Unexpected character: %s\n", yytext); }
%%
