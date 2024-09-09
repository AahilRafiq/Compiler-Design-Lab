%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	#include "lib/table.h"

	char current_identifier[20];
	char current_type[20];
	char current_value[20];
    char current_function[20];
	char previous_operator[20];
	int flag;

%}

num              	[0-9]
alpha              	[a-zA-Z]
alphanum            {alpha}|{num}
escape_sequences    0|a|b|f|n|r|t|v|"\\"|"\""|"\'"
ws  				[ \t\r\f\v]+
%x MLCOMMENT
DE "define"
IN "include"

%%

	int nested_count = 0;
	int check_nested = 0;

\n 	{yylineno++;}
"#include"[ ]*"<"{alpha}({alphanum})*".h>"   { }
"#define"[ ]+(_|{alpha})({alphanum})*[ ]*(.)+   { } 
"//".*  { }

"/*"             { BEGIN MLCOMMENT; }
<MLCOMMENT>"/*"		{ 
	++nested_count; 
	check_nested = 1;
}	
<MLCOMMENT>"*"+"/"  { 
		if (nested_count) --nested_count;
		else{ if(check_nested){
			check_nested = 0;
			BEGIN INITIAL;
		}
		else{
			BEGIN INITIAL;
		}
	} 
}
<MLCOMMENT>"*"+         ; 
<MLCOMMENT>[^/*\n]+	;
<MLCOMMENT>[/]    ;
<MLCOMMENT>\n     ;
<MLCOMMENT><<EOF>> { printf("Line No. %d ERROR: MULTI LINE COMMENT NOT CLOSED\n", yylineno); return 0;}

"[" {return *yytext;}
"]" {return *yytext;}
"(" {return *yytext;}
")" {return *yytext;}
"{" {return *yytext;}
"}" {return *yytext;}
"," {return *yytext;}
";" {return *yytext;}



"char"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword"); return CHAR;}
"double"	{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword"); return DOUBLE;}
"else"		{ insert_SymbolTable_line(yytext, yylineno); insert_SymbolTable(yytext, "Keyword"); return ELSE;}
"float"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");return FLOAT;}
"while"		{ insert_SymbolTable(yytext, "Keyword"); return WHILE;}
"do"		{ insert_SymbolTable(yytext, "Keyword"); return DO;}
"for"		{ insert_SymbolTable(yytext, "Keyword"); return FOR;}
"if"		{ insert_SymbolTable(yytext, "Keyword"); return IF;}
"int"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");return INT;}
"long"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return LONG;}
"return"	{ insert_SymbolTable(yytext, "Keyword");  return RETURN;}
"short"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return SHORT;}
"signed"	{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return SIGNED;}
"sizeof" 	{ insert_SymbolTable(yytext, "Keyword");  return SIZEOF;}
"struct" 	{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return STRUCT;}
"unsigned"	{ insert_SymbolTable(yytext, "Keyword");  return UNSIGNED;}
"void"		{ strcpy(current_type,yytext); insert_SymbolTable(yytext, "Keyword");  return VOID;}
"break"		{ insert_SymbolTable(yytext, "Keyword");  return BREAK;}
"continue"	{ insert_SymbolTable(yytext, "Keyword");  return CONTINUE;}
"goto"		{ insert_SymbolTable(yytext, "Keyword");  return GOTO;}
"switch"	{ insert_SymbolTable(yytext, "Keyword");  return SWITCH;}
"case"		{ insert_SymbolTable(yytext, "Keyword");  return CASE;}
"default"	{ insert_SymbolTable(yytext, "Keyword");  return DEFAULT;}

("\"")[^\n\"]*("\"")                         {strcpy(current_value,yytext); insert_ConstantTable(yytext,"String Constant"); return string_constant;}        
("\"")[^\n\"]*                               { printf("Line No. %d ERROR: UNCLOSED STRING - %s\n", yylineno, yytext); return 0;}
("\'")(("\\"({escape_sequences}))|.)("\'")   {strcpy(current_value,yytext); insert_ConstantTable(yytext,"Character Constant"); return character_constant;}
("\'")(((("\\")[^0abfnrtv\\\"\'][^\n\']*))|[^\n\''][^\n\'']+)("\'") {printf("Line No. %d ERROR: NOT A CHARACTER - %s\n", yylineno, yytext); return 0; }
{num}+(\.{num}+)?e{num}+   		        {strcpy(current_value,yytext); insert_ConstantTable(yytext, "Floating Constant"); return float_constant;} 
{num}+\.{num}+                		    {strcpy(current_value,yytext); insert_ConstantTable(yytext, "Floating Constant"); return float_constant;}                                             
{num}+                           	   	{strcpy(current_value,yytext); insert_ConstantTable(yytext, "Number Constant"); return integer_constant;}    
(_|{alpha})({alpha}|{alpha}|_)*  		{strcpy(current_identifier,yytext);insert_SymbolTable(yytext,"Identifier");  return identifier;}
(_|{alpha})({alpha}|{alpha}|_)*/\[  	{strcpy(current_identifier,yytext);insert_SymbolTable(yytext,"Array Identifier");  return identifier;}
{ws}										 ;

"+"	 {return *yytext;}
"-"	 {return *yytext;}
"*"	 {return *yytext;}
"/"	 {return *yytext;}
"="	 {return *yytext;}
"%"	 {return *yytext;}
"&"	 {return *yytext; }
"^"	 {return *yytext; }
"++" {return INCREMENT;}
"--" {return DECREMENT;}
"!"	 {return NOT;}
"+=" {return ADD_EQUAL;}
"-=" {return SUBTRACT_EQUAL;}
"*=" {return MULTIPLY_EQUAL;}
"/=" {return DIVIDE_EQUAL;}
"%=" {return MOD_EQUAL;}
"&&" {return AND_AND;}

"||"	{return OR_OR;}
">"		{return GREAT;}
"<"		{return LESS;}
">="	{return GREAT_EQUAL;}
"<="	{return LESS_EQUAL;}
"=="	{return EQUAL;}
"!="	{return NOT_EQUAL;}
.		{ flag = 1;
		  if(yytext[0] == '#')
			printf("Line No. %d PREPROCESSOR ERROR - %s\n", yylineno, yytext);
		  else
			printf("Line No. %d ERROR ILLEGAL CHARACTER - %s\n", yylineno, yytext);
		 return 0;}

%%