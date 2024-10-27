%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	void yyerror(char* s);
	int yylex();
	void insertSymbolTableType();
	void insertSymbolTableValueType();
	int flag=0;

	extern char currentIdentifier[20];
	extern char currentType[20];
	extern char currentValue[20];
	extern int currentNestingLevel;
	void deleteData(int);
	int checkScope(char*);
	int checkIfIdentifierIsFunction(char *);
	void insertSymbolTable(char*, char*);
	void insertSymbolTableNesting(char*, int);
	void insertSymbolTableParamsCount(char*, int);
	int getSymbolTableParamsCount(char*);
	int checkDuplicate(char*);
	int checkDeclaration(char*, char *);
	int checkParams(char*);
	int checkDuplicate(char *s);
	int checkArray(char*);
	char currentFunctionType[100];
	char currentFunction[100];
	char currentFunctionCall[100];
	void insertSymbolTableFunction(char*);
	char getType(char*, int);
	char getFirst(char*);
	void push(char *s);
	void generateCode();
	void generateCodeAssignment();
	char* integerToString(int num, char* str, int base);
	void reverseString(char str[], int length); 
	void swapCharacters(char*, char*);
	void generateLabel1();
	void generateLabel2();
	void generateLabel3();
	void generateLabel4();
	void generateLabel5();
	void generateLabel6();
	void generateUnaryCode();
	void generateCodeConstant();
	void generateFunctionCode();
	void generateFunctionEndCode();
	void generateArgumentCode();
	void generateFunctionCallCode();

	int paramsCount=0;
	int callParamsCount=0;
	int top = 0, count=0, labelTop=0, labelNumber=0;
	char temp[3] = "t";
%}

%nonassoc IF
%token INT CHAR FLOAT DOUBLE LONG SHORT SIGNED UNSIGNED STRUCT
%token RETURN MAIN
%token VOID
%token WHILE FOR DO 
%token BREAK
%token ENDIF
%expect 1

%token identifier array_identifier func_identifier
%token integer_constant string_constant float_constant character_constant

%nonassoc ELSE

%right leftshift_assignment_operator rightshift_assignment_operator
%right XOR_assignment_operator OR_assignment_operator
%right AND_assignment_operator modulo_assignment_operator
%right multiplication_assignment_operator division_assignment_operator
%right addition_assignment_operator subtraction_assignment_operator
%right assignment_operator

%left OR_operator
%left AND_operator
%left pipe_operator
%left caret_operator
%left amp_operator
%left equality_operator inequality_operator
%left lessthan_assignment_operator lessthan_operator greaterthan_assignment_operator greaterthan_operator
%left leftshift_operator rightshift_operator 
%left add_operator subtract_operator
%left multiplication_operator division_operator modulo_operator

%right SIZEOF
%right tilde_operator exclamation_operator
%left increment_operator decrement_operator 


%start program

%%
program
			: declaration_list;

declaration_list
			: declaration D 

D
			: declaration_list
			| ;

declaration
			: variable_declaration 
			| function_declaration

variable_declaration
			: type_specifier variable_declaration_list ';' 

variable_declaration_list
			: variable_declaration_list ',' variable_declaration_identifier | variable_declaration_identifier;

variable_declaration_identifier 
			: identifier {if(checkDuplicate(currentIdentifier)){printf("Duplicate\n");exit(0);}insertSymbolTableNesting(currentIdentifier,currentNestingLevel); insertSymbolTableType();  } vdi   
			  | array_identifier {if(checkDuplicate(currentIdentifier)){printf("Duplicate\n");exit(0);}insertSymbolTableNesting(currentIdentifier,currentNestingLevel); insertSymbolTableType();  } vdi;
			
			

vdi : identifier_array_type | assignment_operator simple_expression  ; 

identifier_array_type
			: '[' initilization_params
			| ;

initilization_params
			: integer_constant ']' initilization {if($$ < 1) {printf("Wrong array size\n"); exit(0);} }
			| ']' string_initilization;

initilization
			: string_initilization
			| array_initialization
			| ;

type_specifier 
			: INT | CHAR | FLOAT  | DOUBLE  
			| LONG long_grammar 
			| SHORT short_grammar
			| UNSIGNED unsigned_grammar 
			| SIGNED signed_grammar
			| VOID  ;

unsigned_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

signed_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

long_grammar 
			: INT  | ;

short_grammar 
			: INT | ;

function_declaration
			: function_declaration_type function_declaration_param_statement;

function_declaration_type
			: type_specifier identifier '('  { strcpy(currentFunctionType, currentType); strcpy(currentFunction, currentIdentifier); checkDuplicate(currentIdentifier); insertSymbolTableFunction(currentIdentifier); insertSymbolTableType(); };

function_declaration_param_statement
			: {paramsCount=0;}params ')' {generateFunctionCode();} statement {generateFunctionEndCode();};

params 
			: parameters_list { insertSymbolTableParamsCount(currentFunction, paramsCount); }| { insertSymbolTableParamsCount(currentFunction, paramsCount); };

parameters_list 
			: type_specifier { checkParams(currentType);} parameters_identifier_list ;

parameters_identifier_list 
			: param_identifier parameters_identifier_list_breakup;

parameters_identifier_list_breakup
			: ',' parameters_list 
			| ;

param_identifier 
			: identifier { insertSymbolTableType();insertSymbolTableNesting(currentIdentifier,1); paramsCount++; } param_identifier_breakup;

param_identifier_breakup
			: '[' ']'
			| ;

statement 
			: expression_statment | compound_statement 
			| conditional_statements | iterative_statements 
			| return_statement | break_statement 
			| variable_declaration;

compound_statement 
			: {currentNestingLevel++;} '{'  statment_list  '}' {deleteData(currentNestingLevel);currentNestingLevel--;}  ;

statment_list 
			: statement statment_list 
			| ;

expression_statment 
			: expression ';' 
			| ';' ;

conditional_statements 
			: IF '(' simple_expression ')' {generateLabel1();if($3!=1){printf("Condition checking is not of type int\n");exit(0);}} statement {generateLabel2();}  conditional_statements_breakup;

conditional_statements_breakup
			: ELSE statement {generateLabel3();}
			| {generateLabel3();};

iterative_statements 
			: WHILE '(' {generateLabel4();} simple_expression ')' {generateLabel1();if($4!=1){printf("Condition checking is not of type int\n");exit(0);}} statement {generateLabel5();} 
			| FOR '(' expression ';' {generateLabel4();} simple_expression ';' {generateLabel1();if($6!=1){printf("Condition checking is not of type int\n");exit(0);}} expression ')'statement {generateLabel5();} 
			| {generateLabel4();}DO statement WHILE '(' simple_expression ')'{generateLabel1();generateLabel5();if($6!=1){printf("Condition checking is not of type int\n");exit(0);}} ';';
return_statement 
			: RETURN ';' {if(strcmp(currentFunctionType,"void")) {printf("Returning void of a non-void function\n"); exit(0);}}
			| RETURN expression ';' { 	if(!strcmp(currentFunctionType, "void"))
										{ 
											yyerror("Function is void");
										}

										if((currentFunctionType[0]=='i' || currentFunctionType[0]=='c') && $2!=1)
										{
											printf("Expression doesn't match return type of function\n"); exit(0);
										}

									};

break_statement 
			: BREAK ';' ;

string_initilization
			: assignment_operator string_constant {insertSymbolTableValueType();} ;

array_initialization
			: assignment_operator '{' array_int_declarations '}';

array_int_declarations
			: integer_constant array_int_declarations_breakup;

array_int_declarations_breakup
			: ',' array_int_declarations 
			| ;

expression 
			: mutable assignment_operator {push("=");} expression   {   
																	  if($1==1 && $4==1) 
																	  {
			                                                          $$=1;
			                                                          } 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);} 
			                                                          generateCodeAssignment();
			                                                       }
			| mutable addition_assignment_operator {push("+=");}expression {  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);} 
			                                                          generateCodeAssignment();
			                                                       }
			| mutable subtraction_assignment_operator {push("-=");} expression  {	  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);} 
			                                                          generateCodeAssignment();
			                                                       }
			| mutable multiplication_assignment_operator {push("*=");} expression {
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);}
			                                                          generateCodeAssignment(); 
			                                                       }
			| mutable division_assignment_operator {push("/=");}expression 		{ 
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);} 
			                                                       }
			| mutable modulo_assignment_operator {push("%=");}expression 		{ 
																	  if($1==1 && $3==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Type mismatch\n"); exit(0);} 
			                                                          generateCodeAssignment();
																	}
			| mutable increment_operator 							{ push("++");if($1 == 1) $$=1; else $$=-1; generateUnaryCode();}
			| mutable decrement_operator  							{push("--");if($1 == 1) $$=1; else $$=-1;}
			| simple_expression {if($1 == 1) $$=1; else $$=-1;} ;


simple_expression 
			: simple_expression OR_operator and_expression {push("||");} {if($1 == 1 && $3==1) $$=1; else $$=-1; generateCode();}
			| and_expression {if($1 == 1) $$=1; else $$=-1;};

and_expression 
			: and_expression AND_operator {push("&&");} unary_relation_expression  {if($1 == 1 && $3==1) $$=1; else $$=-1; generateCode();}
			  |unary_relation_expression {if($1 == 1) $$=1; else $$=-1;} ;


unary_relation_expression 
			: exclamation_operator {push("!");} unary_relation_expression {if($2==1) $$=1; else $$=-1; generateCode();} 
			| regular_expression {if($1 == 1) $$=1; else $$=-1;} ;

regular_expression 
			: regular_expression relational_operators sum_expression {if($1 == 1 && $3==1) $$=1; else $$=-1; generateCode();}
			  | sum_expression {if($1 == 1) $$=1; else $$=-1;} ;
			
relational_operators 
			: greaterthan_assignment_operator {push(">=");} | lessthan_assignment_operator {push("<=");} | greaterthan_operator {push(">");}| lessthan_operator {push("<");}| equality_operator {push("==");}| inequality_operator {push("!=");} ;

sum_expression 
			: sum_expression sum_operators term  {if($1 == 1 && $3==1) $$=1; else $$=-1; generateCode();}
			| term {if($1 == 1) $$=1; else $$=-1;};

sum_operators 
			: add_operator {push("+");}
			| subtract_operator {push("-");} ;

term
			: term MULOP factor {if($1 == 1 && $3==1) $$=1; else $$=-1; generateCode();}
			| factor {if($1 == 1) $$=1; else $$=-1;} ;

MULOP 
			: multiplication_operator {push("*");}| division_operator {push("/");} | modulo_operator {push("%");} ;

factor 
			: immutable {if($1 == 1) $$=1; else $$=-1;} 
			| mutable {if($1 == 1) $$=1; else $$=-1;} ;

mutable 
			: identifier {
						  push(currentIdentifier);
						  if(checkIfIdentifierIsFunction(currentIdentifier))
						  {printf("Function name used as Identifier\n"); exit(8);}
			              if(!checkScope(currentIdentifier))
			              {printf("%s\n",currentIdentifier);printf("Undeclared\n");exit(0);} 
			              if(!checkArray(currentIdentifier))
			              {printf("%s\n",currentIdentifier);printf("Array ID has no subscript\n");exit(0);}
			              if(getType(currentIdentifier,0)=='i' || getType(currentIdentifier,1)== 'c')
			              $$ = 1;
			              else
			              $$ = -1;
			              }
			| array_identifier {if(!checkScope(currentIdentifier)){printf("%s\n",currentIdentifier);printf("Undeclared\n");exit(0);}} '[' expression ']' 
			                   {if(getType(currentIdentifier,0)=='i' || getType(currentIdentifier,1)== 'c')
			              		$$ = 1;
			              		else
			              		$$ = -1;
			              		};

immutable 
			: '(' expression ')' {if($2==1) $$=1; else $$=-1;}
			| call {if($1==-1) $$=-1; else $$=1;}
			| constant {if($1==1) $$=1; else $$=-1;};

call
			: identifier '('{

			             if(!checkDeclaration(currentIdentifier, "Function"))
			             { printf("Function not declared"); exit(0);} 
			             insertSymbolTableFunction(currentIdentifier); 
						 strcpy(currentFunctionCall,currentIdentifier);
						 if(getType(currentIdentifier,0)=='i' || getType(currentIdentifier,1)== 'c')
						 {
			             $$ = 1;
			             }
			             else
			             $$ = -1;
                         callParamsCount=0;
			             } 
			             arguments ')' 
						 { if(strcmp(currentFunctionCall,"printf"))
							{ 
								if(getSymbolTableParamsCount(currentFunctionCall)!=callParamsCount)
								{	
									yyerror("Number of arguments in function call doesn't match number of parameters");
									exit(8);
								}
							}
							generateFunctionCallCode();
						 };

arguments 
			: arguments_list | ;

arguments_list 
			: arguments_list ',' exp { callParamsCount++; }  
			| exp { callParamsCount++; };

exp : identifier {generateArgumentCode(1);} | integer_constant {generateArgumentCode(2);} | string_constant {generateArgumentCode(3);} | float_constant {generateArgumentCode(4);} | character_constant {generateArgumentCode(5);} ;

constant 
			: integer_constant 	{  insertSymbolTableValueType(); generateCodeConstant(); $$=1; } 
			| string_constant	{  insertSymbolTableValueType(); generateCodeConstant();$$=-1;} 
			| float_constant	{  insertSymbolTableValueType(); generateCodeConstant();} 
			| character_constant{  insertSymbolTableValueType(); generateCodeConstant();$$=1; };

%%

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
void insertSymbolTableType(char *,char *);
void insertSymbolTableValue(char *, char *);
void insertConstantTable(char *, char *);
void printSymbolTable();
void printConstantTable();

struct stack
{
	char value[100];
	int labelvalue;
}s[100],label[100];


void push(char *x)
{
	strcpy(s[++top].value,x);
}

void swapCharacters(char *x, char *y)
{
	char temp = *x;
	*x = *y;
	*y = temp;
}

void reverseString(char str[], int length) 
{ 
    int start = 0; 
    int end = length -1; 
    while (start < end) 
    { 
        swapCharacters((str+start), (str+end)); 
        start++; 
        end--; 
    } 
} 
  
char* integerToString(int num, char* str, int base) 
{ 
    int i = 0; 
    int isNegative = 0; 
  
   
    if (num == 0) 
    { 
        str[i++] = '0'; 
        str[i] = '\0'; 
        return str; 
    } 
  
    if (num < 0 && base == 10) 
    { 
        isNegative = 1; 
        num = -num; 
    } 
  
   
    while (num != 0) 
    { 
        int rem = num % base; 
        str[i++] = (rem > 9)? (rem-10) + 'a' : rem + '0'; 
        num = num/base; 
    } 
  
    if (isNegative) 
        str[i++] = '-'; 
  
    str[i] = '\0'; 
  
   
    reverseString(str, i); 
  
    return str; 
} 

void generateCode()
{
	strcpy(temp,"t");
	char buffer[100];
	integerToString(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s %s %s\n",temp,s[top-2].value,s[top-1].value,s[top].value);
	top = top - 2;
	strcpy(s[top].value,temp);
	count++; 
}

void generateCodeConstant()
{
	strcpy(temp,"t");
	char buffer[100];
	integerToString(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s\n",temp,currentValue);
	push(temp);
	count++;
	
}

int isUnary(char *s)
{
	if(strcmp(s, "--")==0 || strcmp(s, "++")==0)
	{
		return 1;
	}
	return 0;
}

void generateUnaryCode()
{
	char temp1[100], temp2[100], temp3[100];
	strcpy(temp1, s[top].value);
	strcpy(temp2, s[top-1].value);

	if(isUnary(temp1))
	{
		strcpy(temp3, temp1);
		strcpy(temp1, temp2);
		strcpy(temp2, temp3);
	}
	strcpy(temp, "t");
	char buffer[100];
	integerToString(count, buffer, 10);
	strcat(temp, buffer);
	count++;

	if(strcmp(temp2,"--")==0)
	{
		printf("%s = %s - 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	if(strcmp(temp2,"++")==0)
	{
		printf("%s = %s + 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	top = top -2;
}

void generateCodeAssignment()
{
	printf("%s = %s\n",s[top-2].value,s[top].value);
	top = top - 2;
}

void generateLabel1()
{
	strcpy(temp,"L");
	char buffer[100];
	integerToString(labelNumber,buffer,10);
	strcat(temp,buffer);
	printf("IF not %s GoTo %s\n",s[top].value,temp);
	label[++labelTop].labelvalue = labelNumber++;
}

void generateLabel2()
{
	strcpy(temp,"L");
	char buffer[100];
	integerToString(labelNumber,buffer,10);
	strcat(temp,buffer);
	printf("GoTo %s\n",temp);
	strcpy(temp,"L");
	integerToString(label[labelTop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	labelTop--;
	label[++labelTop].labelvalue=labelNumber++;
}

void generateLabel3()
{
	strcpy(temp,"L");
	char buffer[100];
	integerToString(label[labelTop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	labelTop--;
	
}

void generateLabel4()
{
	strcpy(temp,"L");
	char buffer[100];
	integerToString(labelNumber,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	label[++labelTop].labelvalue = labelNumber++;
}


void generateLabel5()
{
	strcpy(temp,"L");
	char buffer[100];
	integerToString(label[labelTop-1].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("GoTo %s:\n",temp);
	strcpy(temp,"L");
	integerToString(label[labelTop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	labelTop = labelTop - 2;
    
   
}

void generateFunctionCode()
{
	printf("func begin %s\n",currentFunction);
}

void generateFunctionEndCode()
{
	printf("func end\n\n");
}

void generateArgumentCode(int i)
{
    if(i==1)
    {
	printf("refparam %s\n", currentIdentifier);
	}
	else
	{
	printf("refparam %s\n", currentValue);
	}
}

void generateFunctionCallCode()
{
	printf("refparam result\n");
	push("result");
	printf("call %s, %d\n",currentFunctionCall,callParamsCount);
}



int main(int argc , char **argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();

	if(flag == 0)
	{
		printf( "PASSED: ICG Phase\n" );
		printf("%30s"  "PRINTING SYMBOL TABLE"  "\n", " ");
		printf("%30s %s\n", " ", "______________");
		printSymbolTable();

		printf("\n\n%30s"  "PRINTING CONSTANT TABLE"  "\n", " ");
		printf("%30s %s\n", " ", "______________");
		printConstantTable();
	}
}

void yyerror(char *s)
{
	printf( "%d %s %s\n", yylineno, s, yytext);
	flag=1;
	printf( "FAILED: ICG Phase Parsing failed\n" );
	exit(7);
}

void insertSymbolTableType()
{
	insertSymbolTableType(currentIdentifier,currentType);
}

void insertSymbolTableValueType()
{
	insertSymbolTableValue(currentIdentifier,currentValue);
}

int yywrap()
{
	return 1;
}
