%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	#define MAX_TABLE_SIZE 1000

	// Structure for symbol table
	struct symboltable
	{
		char name[100];
		char class[100];
		char type[100];
		char value[100];
		int nesting_val;
		int dimension;
		int lineno;
		int length;
		int params_count;
	}ST[MAX_TABLE_SIZE];

	// Structure for constant table
	struct constanttable
	{
		char name[100];
		char type[100];
		int length;
	}CT[MAX_TABLE_SIZE];

	int current_nesting = 0;
	int params_count = 0;
	extern int curr_dimension;
	extern int yylval;
	extern void deletedata (int );
	extern int checkscope(char*);
	extern int check_id_is_func(char *);
	extern void insertST(char*, char*);
	extern void insertSTnest(char*, int);
	extern void insertSTparamscount(char*, int);
	extern int getSTparamscount(char*);
	extern int check_duplicate(char*);
	extern int check_declaration(char*, char *);
	extern int check_params(char*);
	extern int duplicate(char *s);
	extern void insertSTDimension(char*, int);
	extern int checkarray(char*);
	extern char currfunctype[100];
	extern char currfunc[100];
	extern char currfunccall[100];
	extern void insertSTF(char*);
	extern char gettype(char*,int);
	extern char getfirst(char*);

	// Hash function to generate hash value for a string
	int hash(char *str)
	{
		int value = 0;
		for(int i = 0 ; i < strlen(str) ; i++)
		{
			value = 10*value + (str[i] - 'A');
			value = value % MAX_TABLE_SIZE;
			while(value < 0)
				value = value + MAX_TABLE_SIZE;
		}
		return value;
	}

	// Lookup function for symbol table
	int lookupST(char *str)
	{
		int value = hash(str);
		if(ST[value].length == 0)
		{
			return 0;
		}
		else if(strcmp(ST[value].name,str)==0)
		{
			
			return value;
		}
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%MAX_TABLE_SIZE)
			{
				if(strcmp(ST[i].name,str)==0)
				{
					
					return i;
				}
			}
			return 0;
		}
	}

	// Lookup function for constant table
	int lookupCT(char *str)
	{
		int value = hash(str);
		if(CT[value].length == 0)
			return 0;
		else if(strcmp(CT[value].name,str)==0)
			return 1;
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%MAX_TABLE_SIZE)
			{
				if(strcmp(CT[i].name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}

	// Insert line number in symbol table
	void insertSTline(char *str1, int line)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,str1)==0)
			{
				ST[i].lineno = line;
			}
		}
	}

	// Insert symbol in symbol table
	void insertST(char *str1, char *str2)
	{
		if(lookupST(str1))
		{
			if(strcmp(ST[lookupST(str1)].class,"Identifier")==0 && strcmp(str2,"Array Identifier")==0)
			{
				printf("Error use of array\n");
				exit(0);
			}	
			return;
		}
		else
		{
			int value = hash(str1);
			if(ST[value].length == 0)
			{
				strcpy(ST[value].name,str1);
				strcpy(ST[value].class,str2);
				ST[value].length = strlen(str1);
				ST[value].nesting_val = 9999;
				ST[value].params_count = -1;
				insertSTline(str1,yylineno);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%MAX_TABLE_SIZE)
			{
				if(ST[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(ST[pos].name,str1);
			strcpy(ST[pos].class,str2);
			ST[pos].length = strlen(str1);
			ST[pos].nesting_val = 9999;
			ST[pos].params_count = -1;
		}
	}

	// Insert type in symbol table
	void insertSTtype(char *str1, char *str2)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,str1)==0)
			{
				strcpy(ST[i].type,str2);
			}
		}
    }

	// Insert value in symbol table
	void insertSTvalue(char *str1, char *str2)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,str1)==0 && ST[i].nesting_val == current_nesting)
			{
				strcpy(ST[i].value,str2);
			}
		}
	}

	// Insert dimension in symbol table
	void insertSTDimension(char *str1, int dim)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,str1)==0)
			{
				ST[i].dimension = dim;
			}
		}
	}

	// Insert nesting value in symbol table
	void insertSTnest(char *s, int nest)
	{
		if(lookupST(s) && ST[lookupST(s)].nesting_val != 9999)
		{
             int pos = 0;
             int value = hash(s);
			for (int i = value + 1 ; i!=value ; i = (i+1)%MAX_TABLE_SIZE)
			{
				if(ST[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(ST[pos].name,s);
			strcpy(ST[pos].class,"Identifier");
			ST[pos].length = strlen(s);
			ST[pos].nesting_val = nest;
			ST[pos].params_count = -1;
			ST[pos].lineno = yylineno;
		}
		else
		{
			for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
			{
				if(strcmp(ST[i].name,s)==0 )
				{
					ST[i].nesting_val = nest;
				}
			}
		}
	}

	// Insert parameter count in symbol table
	void insertSTparamscount(char *s, int count)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,s)==0 )
			{
				ST[i].params_count = count;
			}
		}
	}

	// Get parameter count from symbol table
	int getSTparamscount(char *s)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,s)==0 )
			{
				return ST[i].params_count;
			}
		}
		return -2;
	}

	// Insert function in symbol table
	void insertSTF(char *s)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(strcmp(ST[i].name,s)==0 )
			{
				strcpy(ST[i].class,"Function");
				return;
			}
		}

	}

	// Insert constant in constant table
	void insertCT(char *str1, char *str2)
	{
		if(lookupCT(str1))
			return;
		else
		{
			int value = hash(str1);
			if(CT[value].length == 0)
			{
				strcpy(CT[value].name,str1);
				strcpy(CT[value].type,str2);
				CT[value].length = strlen(str1);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%MAX_TABLE_SIZE)
			{
				if(CT[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(CT[pos].name,str1);
			strcpy(CT[pos].type,str2);
			CT[pos].length = strlen(str1);
		}
	}

	// Delete data from symbol table based on nesting value
	void deletedata (int nesting)
	{
		for(int i = 0 ; i < MAX_TABLE_SIZE ; i++)
		{
			if(ST[i].nesting_val == nesting)
			{
				ST[i].nesting_val = 99999;
			}
		}
	}

	// Check scope of a symbol
	int checkscope(char *s)
	{
		int flag = 0;
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(ST[i].name,s)==0)
			{
				if(ST[i].nesting_val > current_nesting)
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

	// Check if identifier is a function
	int check_id_is_func(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(ST[i].name,s)==0)
			{
				if(strcmp(ST[i].class,"Function")==0)
					return 1;
			}
		}
		return 0;
	}

	// Check if symbol is an array
	int checkarray(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(ST[i].name,s)==0)
			{
				if(strcmp(ST[i].class,"Array Identifier")==0)
				{
					return 0;
				}
			}
		}
		return 1;
	}

	// Check for duplicate symbol in the same scope
	int duplicate(char *s)
	{
		for(int i = 0 ; i < 1000 ; i++)
		{
			if(strcmp(ST[i].name,s)==0)
			{				
				if(ST[i].nesting_val == current_nesting)
				{
			        return 1;
				}
			}
		}
		
		return 0;
	}

	// Check for duplicate function declaration
	int check_duplicate(char* str)
	{
		for(int i=0; i<MAX_TABLE_SIZE; i++)
		{
			if(strcmp(ST[i].name, str) == 0 && strcmp(ST[i].class, "Function") == 0)
			{
				printf("Function redeclaration not allowed\n");
				exit(0);
			}
		}
	}

	// Check if function is declared
	int check_declaration(char* str, char *check_type)
	{
		for(int i=0; i<MAX_TABLE_SIZE; i++)
		{
			if(strcmp(ST[i].name, str) == 0 && strcmp(ST[i].class, "Function") == 0 || strcmp(ST[i].name,"printf")==0 )
			{
				return 1;
			}
		}
		return 0;
	}

	// Check if parameters are valid
	int check_params(char* type_specifier)
	{
		if(!strcmp(type_specifier, "void"))
		{
			printf("Parameters cannot be of type void\n");
			exit(0);
		}
		return 0;
	}

	// Get type of a symbol
	char gettype(char *s, int flag)
	{
			for(int i = 0 ; i < MAX_TABLE_SIZE ; i++ )
			{
				if(strcmp(ST[i].name,s)==0)
				{
					return ST[i].type[0];
				}
			}
		
	}

	// Print symbol table
	void printST()
	{
		// Boxed table header
		printf("+-----------------+------------------------+------------+------------+----------+-----------------+------------+\n");
		printf("| %-15s | %-20s | %-10s | %-10s | %-8s | %-15s | %-10s |\n",
			"Symbol Name", "Class", "Type", "Value", "Line No.", "Count of Params", "Dimension");
		printf("+-----------------+------------------------+------------+------------+----------+-----------------+------------+\n");

		// Print each symbol in the table
		for (int i = 0; i < MAX_TABLE_SIZE; i++) {
			if (ST[i].length == 0) {
				continue;
			}
			printf("| %-15s | %-20s | %-10s | %-10s | %-8d | %-15d | %-10d |\n",
				ST[i].name, ST[i].class, ST[i].type, ST[i].value, ST[i].lineno, ST[i].params_count, ST[i].dimension);
		}

		// Bottom border of the table
		printf("+-----------------+------------------------+------------+------------+----------+-----------------+------------+\n");
	}

	// Print constant table
	void printCT()
	{
		// Boxed table header for constants
		printf("+-----------------+-----------------+\n");
		printf("| %-15s | %-15s |\n", "Constant Name", "Constant Type");
		printf("+-----------------+-----------------+\n");

		// Print each constant in the table
		for (int i = 0; i < MAX_TABLE_SIZE; i++) {
			if (CT[i].length == 0) {
				continue;
			}
			printf("| %-15s | %-15s |\n", CT[i].name, CT[i].type);
		}

		// Bottom border of the table
		printf("+-----------------+-----------------+\n");
	}

	char curid[20];
	char curtype[20];
	char curval[20];

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

"char"			{ strcpy(curtype,yytext); insertST(yytext, "Keyword");return CHAR;}
"double"		{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return DOUBLE;}
"else"			{ insertST(yytext, "Keyword"); return ELSE;}
"float"			{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return FLOAT;}
"while"			{ insertST(yytext, "Keyword"); return WHILE;}
"do"			{ insertST(yytext, "Keyword"); return DO;}
"for"			{ insertST(yytext, "Keyword"); return FOR;}
"if"			{ insertST(yytext, "Keyword"); return IF;}
"int"			{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return INT;}
"long"			{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return LONG;}
"return"		{ insertST(yytext, "Keyword"); return RETURN;}
"short"			{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return SHORT;}
"signed"		{ strcpy(curtype,yytext); insertST(yytext, "Keyword"); return SIGNED;}
"sizeof" 		{ insertST(yytext, "Keyword"); return SIZEOF;}
"struct"		{ strcpy(curtype,yytext);   insertST(yytext, "Keyword");  return STRUCT;}
"unsigned"		{ insertST(yytext, "Keyword");   return UNSIGNED;}
"void"			{ strcpy(curtype,yytext);   insertST(yytext, "Keyword");  return VOID;}
"break"			{ insertST(yytext, "Keyword");  return BREAK;}



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

\"[^\n]*\"/[;|,|\)] 			{strcpy(curval,yytext); insertCT(yytext,"String Constant"); return string_constant;}
\'[A-Z|a-z]\'/[;|,|\)|:] 		{strcpy(curval,yytext); insertCT(yytext,"Character Constant"); return character_constant;}
[a-z|A-Z]([a-z|A-Z]|[0-9])*/\[ 	{strcpy(curid,yytext); insertST(yytext, "Array Identifier");  return array_identifier;}
[1-9][0-9]*|0/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\]|\}|:|\n|\t|\^] 	{strcpy(curval,yytext); insertCT(yytext, "Number Constant"); yylval = atoi(yytext); return integer_constant;}
([0-9]*)\.([0-9]+)/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\n|\t|\^] 	{strcpy(curval,yytext); insertCT(yytext, "Floating Constant"); return float_constant;}
[A-Za-z_][A-Za-z_0-9]* {strcpy(curid,yytext); insertST(curid,"Identifier"); return identifier;}

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
