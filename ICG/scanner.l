%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "y.tab.h"

	// Structure to represent a symbol table entry
	struct symboltable
	{
		char name[100];
		char class[100];
		char type[100];
		char value[100];
		int nesting_level;
		int line_number;
		int length;
		int params_count;
	}symbol_table[1007];

	// Structure to represent a constant table entry
	struct constanttable
	{
		char name[100];
		char type[100];
		int length;
	}constant_table[1007];

	int current_nesting_level = 0;
	extern int yylval;

	// Hash function to generate a hash value for a given string
	int hash(char *str)
	{
		int value = 0;
		for(int i = 0 ; i < strlen(str) ; i++)
		{
			value = 10*value + (str[i] - 'A');
			value = value % 1007;
			while(value < 0)
				value = value + 1007;
		}
		return value;
	}

	// Function to look up a symbol in the symbol table
	int lookupSymbolTable(char *str)
	{
		int value = hash(str);
		if(symbol_table[value].length == 0)
		{
			return 0;
		}
		else if(strcmp(symbol_table[value].name,str)==0)
		{
			
			return value;
		}
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%1007)
			{
				if(strcmp(symbol_table[i].name,str)==0)
				{
					
					return i;
				}
			}
			return 0;
		}
	}

	// Function to look up a constant in the constant table
	int lookupConstantTable(char *str)
	{
		int value = hash(str);
		if(constant_table[value].length == 0)
			return 0;
		else if(strcmp(constant_table[value].name,str)==0)
			return 1;
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%1007)
			{
				if(strcmp(constant_table[i].name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}

	// Function to insert a line number for a symbol in the symbol table
	void insertSymbolTableLine(char *str1, int line)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,str1)==0)
			{
				symbol_table[i].line_number = line;
			}
		}
	}

	// Function to insert a symbol into the symbol table
	void insertSymbolTable(char *str1, char *str2)
	{
		if(lookupSymbolTable(str1))
		{
			if(strcmp(symbol_table[lookupSymbolTable(str1)].class,"Identifier")==0 && strcmp(str2,"Array Identifier")==0)
			{
				printf("Error use of array\n");
				exit(0);
			}	
			return;
		}
		else
		{
			int value = hash(str1);
			if(symbol_table[value].length == 0)
			{
				strcpy(symbol_table[value].name,str1);
				strcpy(symbol_table[value].class,str2);
				symbol_table[value].length = strlen(str1);
				symbol_table[value].nesting_level = 9999;
				symbol_table[value].params_count = -1;
				insertSymbolTableLine(str1,yylineno);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%1007)
			{
				if(symbol_table[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(symbol_table[pos].name,str1);
			strcpy(symbol_table[pos].class,str2);
			symbol_table[pos].length = strlen(str1);
			symbol_table[pos].nesting_level = 9999;
			symbol_table[pos].params_count = -1;
		}
	}

	// Function to insert a type for a symbol in the symbol table
	void insertSymbolTableType(char *str1, char *str2)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,str1)==0)
			{
				strcpy(symbol_table[i].type,str2);
			}
		}
    }

	// Function to insert a value for a symbol in the symbol table
	void insertSymbolTableValue(char *str1, char *str2)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,str1)==0 && symbol_table[i].nesting_level == current_nesting_level)
			{
				strcpy(symbol_table[i].value,str2);
			}
		}
	}

	// Function to insert a nesting level for a symbol in the symbol table
	void insertSymbolTableNesting(char *s, int nest)
	{
		if(lookupSymbolTable(s) && symbol_table[lookupSymbolTable(s)].nesting_level != 9999)
		{
             int pos = 0;
             int value = hash(s);
			for (int i = value + 1 ; i!=value ; i = (i+1)%1007)
			{
				if(symbol_table[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(symbol_table[pos].name,s);
			strcpy(symbol_table[pos].class,"Identifier");
			symbol_table[pos].length = strlen(s);
			symbol_table[pos].nesting_level = nest;
			symbol_table[pos].params_count = -1;
			symbol_table[pos].line_number = yylineno;
		}
		else
		{
			for(int i = 0 ; i < 1007 ; i++)
			{
				if(strcmp(symbol_table[i].name,s)==0 )
				{
					symbol_table[i].nesting_level = nest;
				}
			}
		}
	}

	// Function to insert a parameter count for a symbol in the symbol table
	void insertSymbolTableParamsCount(char *s, int count1)
	{

		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0 )
			{
				symbol_table[i].params_count = count1;
			}
		}
	}

	// Function to get the parameter count for a symbol in the symbol table
	int getSymbolTableParamsCount(char *s)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0 )
			{
				return symbol_table[i].params_count;
			}
		}
		return -1;
	}

	// Function to insert a function symbol in the symbol table
	void insertSymbolTableFunction(char *s)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0 )
			{
				strcpy(symbol_table[i].class,"Function");
				return;
			}
		}

	}

	// Function to insert a constant into the constant table
	void insertConstantTable(char *str1, char *str2)
	{
		if(lookupConstantTable(str1))
			return;
		else
		{
			int value = hash(str1);
			if(constant_table[value].length == 0)
			{
				strcpy(constant_table[value].name,str1);
				strcpy(constant_table[value].type,str2);
				constant_table[value].length = strlen(str1);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%1007)
			{
				if(constant_table[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(constant_table[pos].name,str1);
			strcpy(constant_table[pos].type,str2);
			constant_table[pos].length = strlen(str1);
		}
	}

	// Function to delete data from the symbol table based on nesting level
	void deleteData (int nesting)
	{
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(symbol_table[i].nesting_level == nesting)
			{
				symbol_table[i].nesting_level = 99999;
			}
		}


	}

	// Function to check the scope of a symbol
	int checkScope(char *s)
	{
		int flag = 0;
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0)
			{
				if(symbol_table[i].nesting_level > current_nesting_level)
				{
					flag = 1;
				}
				else
				{
					flag = 0;
					break;
				}
			}
		}
		if(!flag)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}

	// Function to check if an identifier is a function
	int checkIfIdentifierIsFunction(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0)
			{
				if(strcmp(symbol_table[i].class,"Function")==0)
					return 1;
			}
		}
		return 0;
	}

	// Function to check if a symbol is an array
	int checkArray(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0)
			{
				if(strcmp(symbol_table[i].class,"Array Identifier")==0)
				{
					return 0;
				}
			}
		}
		return 1;
	}

	// Function to check for duplicate symbols in the current scope
	int checkDuplicate(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(symbol_table[i].name,s)==0)
			{				
				if(symbol_table[i].nesting_level == current_nesting_level)
				{
			        return 1;
				}
			}
		}
		
		return 0;
	}

	// Function to check for duplicate function declarations
	int checkFunctionDuplicate(char* str)
	{
		for(int i=0; i<1007; i++)
		{
			if(strcmp(symbol_table[i].name, str) == 0 && strcmp(symbol_table[i].class, "Function") == 0)
			{
				printf("Function redeclaration not allowed\n");
				exit(0);
			}
		}
	}

	// Function to check if a function is declared
	int checkFunctionDeclaration(char* str, char *check_type)
	{
		for(int i=0; i<1007; i++)
		{
			if(strcmp(symbol_table[i].name, str) == 0 && strcmp(symbol_table[i].class, "Function") == 0 || strcmp(symbol_table[i].name,"printf")==0 )
			{
				return 1;
			}
		}
		return 0;
	}

	// Function to check if function parameters are valid
	int checkFunctionParams(char* type_specifier)
	{
		if(!strcmp(type_specifier, "void"))
		{
			printf("Parameters cannot be of type void\n");
			exit(0);
		}
		return 0;
	}

	// Function to get the type of a symbol
	char getType(char *s, int flag)
	{
			for(int i = 0 ; i < 1007 ; i++ )
			{
				if(strcmp(symbol_table[i].name,s)==0)
				{
					return symbol_table[i].type[0];
				}
			}
		
	}

	// Function to print the symbol table
	void printSymbolTable()
	{
		printf("%10s | %15s | %10s | %10s | %10s | %15s | %10s |\n","Symbol Name", "Class", "Type","Value", "Line No.", "Nesting Count", "Params Count");
		for(int i=0;i<120;i++) {
			printf("_");
		}
		printf("\n");
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(symbol_table[i].length == 0)
			{
				continue;
			}
			printf("%10s | %15s | %10s | %10s | %10d | %15d | %10d |\n",symbol_table[i].name, symbol_table[i].class, symbol_table[i].type, symbol_table[i].value, symbol_table[i].line_number, symbol_table[i].nesting_level, symbol_table[i].params_count);
		}
    }

	// Function to print the constant table
	void printConstantTable()
	{
		printf("%10s | %15s\n","constant name", "Type");
		for(int i=0;i<110;i++) {
			printf("_");
		}
		printf("\n");
		for(int i = 0 ; i < 1007 ; i++)
		{
			if(constant_table[i].length == 0)
				continue;

			printf("%10s | %15s\n",constant_table[i].name, constant_table[i].type);
		}
	}
	char currentIdentifier[20];
	char currentType[20];
	char currentValue[20];

%}

DE "define"
IN "include"

%%
\n 	{yylineno++;}
([#][" "]*({IN})[ ]*([<]?)([A-Za-z]+)[.]?([A-Za-z]*)([>]?))/["\n"|\/|" "|"\t"]	{ }
([#][" "]*({DE})[" "]*([A-Za-z]+)(" ")*[0-9]+)/["\n"|\/|" "|"\t"]				{ } 
\/\/(.*)																		{ }
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/										{ }
[ \n\t] ;
";"				{ return(';'); }
","				{ return(','); }
("{")			{ return('{'); }
("}")			{ return('}'); }
"("				{ return('('); }
")"				{ return(')'); }
("["|"<:")		{ return('['); }
("]"|":>") 		{ return(']'); }
":"				{ return(':'); }
"."				{ return('.'); }

"char"			{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword");return CHAR;}
"double"		{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return DOUBLE;}
"else"			{ insertSymbolTable(yytext, "Keyword"); return ELSE;}
"float"			{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return FLOAT;}
"while"			{ insertSymbolTable(yytext, "Keyword"); return WHILE;}
"do"			{ insertSymbolTable(yytext, "Keyword"); return DO;}
"for"			{ insertSymbolTable(yytext, "Keyword"); return FOR;}
"if"			{ insertSymbolTable(yytext, "Keyword"); return IF;}
"int"			{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return INT;}
"long"			{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return LONG;}
"return"		{ insertSymbolTable(yytext, "Keyword"); return RETURN;}
"short"			{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return SHORT;}
"signed"		{ strcpy(currentType,yytext); insertSymbolTable(yytext, "Keyword"); return SIGNED;}
"sizeof" 		{ insertSymbolTable(yytext, "Keyword"); return SIZEOF;}
"struct"		{ strcpy(currentType,yytext);   insertSymbolTable(yytext, "Keyword");  return STRUCT;}
"unsigned"		{ insertSymbolTable(yytext, "Keyword");   return UNSIGNED;}
"void"			{ strcpy(currentType,yytext);   insertSymbolTable(yytext, "Keyword");  return VOID;}
"break"			{ insertSymbolTable(yytext, "Keyword");  return BREAK;}



"++"			{ return increment_operator; }
"--"			{ return decrement_operator; }
"<<"			{ return leftshift_operator; }
">>"			{ return rightshift_operator; }
"<="			{ return lessthan_assignment_operator; }
"<"				{ return lessthan_operator; }
">="			{ return greaterthan_assignment_operator; }
">"				{ return greaterthan_operator; }
"=="			{ return equality_operator; }
"!="			{ return inequality_operator; }
"&&"			{ return AND_operator; }
"||"			{ return OR_operator; }
"^"				{ return caret_operator; }
"*="			{ return multiplication_assignment_operator; }
"/="			{ return division_assignment_operator; }
"%="			{ return modulo_assignment_operator; }
"+="			{ return addition_assignment_operator; }
"-="			{ return subtraction_assignment_operator; }
"<<="			{ return leftshift_assignment_operator; }
">>="			{ return rightshift_assignment_operator; }
"&="			{ return AND_assignment_operator; }
"^="			{ return XOR_assignment_operator; }
"|="			{ return OR_assignment_operator; }
"&"				{ return amp_operator; }
"!"				{ return exclamation_operator; }
"~"				{ return tilde_operator; }
"-"				{ return subtract_operator; }
"+"				{ return add_operator; }
"*"				{ return multiplication_operator; }
"/"				{ return division_operator; }
"%"				{ return modulo_operator; }
"|"				{ return pipe_operator; }
\=				{ return assignment_operator;}

\"[^\n]*\"/[;|,|\)] 			{strcpy(currentValue,yytext); insertConstantTable(yytext,"String Constant"); return string_constant;}
\'[A-Z|a-z]\'/[;|,|\)|:] 		{strcpy(currentValue,yytext); insertConstantTable(yytext,"Character Constant"); return character_constant;}
[a-z|A-Z]([a-z|A-Z]|[0-9])*/\[ 	{strcpy(currentIdentifier,yytext); insertSymbolTable(yytext, "Array Identifier");  return array_identifier;}
[1-9][0-9]*|0/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\]|\}|:|\n|\t|\^] 	{strcpy(currentValue,yytext); insertConstantTable(yytext, "Number Constant"); yylval = atoi(yytext); return integer_constant;}
([0-9]*)\.([0-9]+)/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\n|\t|\^] 	{strcpy(currentValue,yytext); insertConstantTable(yytext, "Floating Constant"); return float_constant;}
[A-Za-z_][A-Za-z_0-9]* {strcpy(currentIdentifier,yytext); insertSymbolTable(currentIdentifier,"Identifier"); return identifier;}

(.?) {
		if(yytext[0]=='#')
		{
			printf("Error in Pre-Processor directive at line no. %d\n",yylineno);
		}
		else if(yytext[0]=='/')
		{
			printf("ERR_UNMATCHED_COMMENT at line no. %d\n",yylineno);
		}
		else if(yytext[0]=='"')
		{
			printf("ERR_INCOMPLETE_STRING at line no. %d\n",yylineno);
		}
		else
		{
			printf("ERROR at line no. %d\n",yylineno);
		}
		printf("%s\n", yytext);
		return 0;
}

%%
