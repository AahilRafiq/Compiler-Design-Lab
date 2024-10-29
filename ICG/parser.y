%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "icg.h"
	
	void yyerror(char* s);
	int yylex();
	void ins();
	void insV();
	int curr_dimension = 0;
	int flag=0;
	int printFnCallFlag = 0;

	extern char curid[20];
	extern int yylineno;
	extern char curtype[20];
	extern char curval[20];
	extern int currnest;
	void insert_icg(char *instr);
	void print_icg();
	void insertSTDimension(char*, int);
	void deletedata (int );
	int checkscope(char*);
	int check_id_is_func(char *);
	void insertST(char*, char*);
	void insertSTnest(char*, int);
	void insertSTparamscount(char*, int);
	int getSTparamscount(char*);
	int check_duplicate(char*);
	int check_declaration(char*, char *);
	int check_params(char*);
	int duplicate(char *s);
	int checkarray(char*);
	char currfunctype[100];
	char currfunc[100];
	char currfunccall[100];
	void insertSTF(char*);
	char gettype(char*,int);
	char getfirst(char*);
	void push(char *s);
	void codegen();
	void codeassign();
	char* itoa(int num, char* str, int base);
	void reverse(char str[], int length); 
	void swap(char*,char*);
	void label_start_conditional();
	void label_else_conditional();
	void label_exit_conditional();
	void label_loop_conditional();
	void label_loop_end();
	void label6();
	void genunary();
	void codegencon();
	void funcgen();
	void funcgenend();
	void arggen();
	void callgen();

	int params_count=0;
	int call_params_count=0;
	int top = 0,count=0,ltop=0,lno=0;
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
			: identifier {if(duplicate(curid)){printf("Line %d : Duplicate\n",yylineno);exit(0);}insertSTnest(curid,currnest); ins();  } vdi   
			//   | array_identifier {if(duplicate(curid)){printf("Duplicate\n");exit(0);}insertSTnest(curid,currnest); ins();  } vdi;
			 | array_identifier {curr_dimension=0;if(duplicate(curid)){printf("Line %d : Duplicate\n",yylineno);exit(0);}insertSTnest(curid,currnest); ins();  } vdi;	
			

vdi : identifier_array_type | assignment_operator simple_expression  ; 

identifier_array_type
			: '[' initilization_params {curr_dimension++;insertSTDimension(curid,curr_dimension);}
			| ;

initilization_params
			: integer_constant ']' identifier_array_type initilization {if($$ < 1) {printf("Line %d : Wrong array size\n",yylineno); exit(0);} }
			/* | integer_constant ']' identifier_array_type {if($$ < 1) {printf("Wrong array size\n"); exit(0);} } */
			;

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
			: type_specifier identifier '('  { strcpy(currfunctype, curtype); strcpy(currfunc, curid); check_duplicate(curid); insertSTF(curid); ins(); };

function_declaration_param_statement
			: {params_count=0;}params ')' {funcgen();} statement {funcgenend();};

params 
			: parameters_list { insertSTparamscount(currfunc, params_count); }| { insertSTparamscount(currfunc, params_count); };

parameters_list 
			: type_specifier { check_params(curtype);} parameters_identifier_list ;

parameters_identifier_list 
			: param_identifier parameters_identifier_list_breakup;

parameters_identifier_list_breakup
			: ',' parameters_list 
			| ;

param_identifier 
			: identifier { ins();insertSTnest(curid,1); params_count++; } param_identifier_breakup;

param_identifier_breakup
			: '[' ']'
			| ;

statement 
			: expression_statment | compound_statement 
			| conditional_statements | iterative_statements 
			| return_statement | break_statement 
			| variable_declaration;

compound_statement 
			: {currnest++;} '{'  statment_list  '}' {deletedata(currnest);currnest--;}  ;

statment_list 
			: statement statment_list 
			| ;

expression_statment 
			: expression ';' 
			| ';' ;

conditional_statements 
			: IF '(' simple_expression ')' {label_start_conditional();if($3!=1){printf("Line %d : Condition checking is not of type int\n",yylineno);exit(0);}} statement {label_else_conditional();}  conditional_statements_breakup;

conditional_statements_breakup
			: ELSE statement {label_exit_conditional();}
			| {label_exit_conditional();};

iterative_statements 
			: WHILE '(' {label_loop_conditional();} simple_expression ')' {label_start_conditional();if($4!=1){printf("Line %d : Condition checking is not of type int\n",yylineno);exit(0);}} statement {label_loop_end();} 
			| FOR '(' expression ';' {label_loop_conditional();} simple_expression ';' {label_start_conditional();if($6!=1){printf("Line %d : Condition checking is not of type int\n",yylineno);exit(0);}} expression ')'statement {label_loop_end();} 
			| {label_loop_conditional();}DO statement WHILE '(' simple_expression ')'{label_start_conditional();label_loop_end();if($6!=1){printf("Line %d : Condition checking is not of type int\n",yylineno);exit(0);}} ';';
return_statement 
			: RETURN ';' {if(strcmp(currfunctype,"void")) {printf("Line %d : Returning void of a non-void function\n",yylineno); exit(0);}}
			| RETURN expression ';' { 	if(!strcmp(currfunctype, "void"))
										{ 
											yyerror("Function is void");
										}

										if((currfunctype[0]=='i' || currfunctype[0]=='c') && $2!=1)
										{
											printf("Line %d : Expression doesn't match return type of function\n",yylineno); exit(0);
										}

									};

break_statement 
			: BREAK ';' ;

string_initilization
			: assignment_operator string_constant {insV();} ;

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
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable addition_assignment_operator {push("+=");}expression {  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable subtraction_assignment_operator {push("-=");} expression  {	  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable multiplication_assignment_operator {push("*=");} expression {
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);}
			                                                          codeassign(); 
			                                                       }
			| mutable division_assignment_operator {push("/=");}expression 		{ 
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);} 
			                                                       }
			| mutable modulo_assignment_operator {push("%=");}expression 		{ 
																	  if($1==1 && $3==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Line %d : Type mismatch\n",yylineno); exit(0);} 
			                                                          codeassign();
																	}
			| mutable increment_operator 							{ push("++");if($1 == 1) $$=1; else $$=-1; genunary();}
			| mutable decrement_operator  							{push("--");if($1 == 1) $$=1; else $$=-1;}
			| simple_expression {if($1 == 1) $$=1; else $$=-1;} ;


simple_expression 
			: simple_expression OR_operator and_expression {push("||");} {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| and_expression {if($1 == 1) $$=1; else $$=-1;};

and_expression 
			: and_expression AND_operator {push("&&");} unary_relation_expression  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  |unary_relation_expression {if($1 == 1) $$=1; else $$=-1;} ;


unary_relation_expression 
			: exclamation_operator {push("!");} unary_relation_expression {if($2==1) $$=1; else $$=-1; codegen();} 
			| regular_expression {if($1 == 1) $$=1; else $$=-1;} ;

regular_expression 
			: regular_expression relational_operators sum_expression {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  | sum_expression {if($1 == 1) $$=1; else $$=-1;} ;
			
relational_operators 
			: greaterthan_assignment_operator {push(">=");} | lessthan_assignment_operator {push("<=");} | greaterthan_operator {push(">");}| lessthan_operator {push("<");}| equality_operator {push("==");}| inequality_operator {push("!=");} ;

sum_expression 
			: sum_expression sum_operators term  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| term {if($1 == 1) $$=1; else $$=-1;};

sum_operators 
			: add_operator {push("+");}
			| subtract_operator {push("-");} ;

term
			: term MULOP factor {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| factor {if($1 == 1) $$=1; else $$=-1;} ;

MULOP 
			: multiplication_operator {push("*");}| division_operator {push("/");} | modulo_operator {push("%");} ;

factor 
			: immutable {if($1 == 1) $$=1; else $$=-1;} 
			| mutable {if($1 == 1) $$=1; else $$=-1;} ;

mutable 
			: identifier {
						  push(curid);
						  if(check_id_is_func(curid))
						  {printf("Line %d : Function name used as Identifier\n",yylineno); exit(8);}
			              if(!checkscope(curid))
			              {printf("%s\n",curid);printf("Line %d : Undeclared\n",yylineno);exit(0);} 
			              if(!checkarray(curid))
			              {printf("%s\n",curid);printf("Line %d : Array ID has no subscript\n",yylineno);exit(0);}
			              if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
			              $$ = 1;
			              else
			              $$ = -1;
			              }
			| array_identifier {if(!checkscope(curid)){printf("%s\n",curid);printf("Line %d : Undeclared\n",yylineno);exit(0);}} '[' expression ']' 
			                   {if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
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

			             if(!check_declaration(curid, "Function"))
			             { printf("Line %d : Function not declared",yylineno); exit(0);} 
			             insertSTF(curid); 
						 strcpy(currfunccall,curid);
						 if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
						 {
			             $$ = 1;
			             }
			             else
			             $$ = -1;
                         call_params_count=0;
			             } 
			             arguments ')' 
						 { if(strcmp(currfunccall,"printf"))
							{ 
								if(getSTparamscount(currfunccall)!=call_params_count)
								{	
									yyerror("Number of arguments in function call doesn't match number of parameters");
									exit(8);
								}
							}
							callgen();
						 };

arguments 
			: arguments_list | ;

arguments_list 
			: arguments_list ',' exp { call_params_count++; }  
			| exp { call_params_count++; };

exp : identifier {arggen(1);} | integer_constant {arggen(2);} | string_constant {arggen(3);} | float_constant {arggen(4);} | character_constant {arggen(5);} ;

constant 
			: integer_constant 	{  insV(); codegencon(); $$=1; } 
			| string_constant	{  insV(); codegencon();$$=-1;} 
			| float_constant	{  insV(); codegencon();} 
			| character_constant{  insV(); codegencon();$$=1; };

%%

extern FILE *yyin;
extern char *yytext;
void insertSTtype(char *,char *);
void insertSTvalue(char *, char *);
void incertCT(char *, char *);
void printST();
void printCT();

struct stack
{
	char value[100];
	int labelvalue;
}s[100],label[100];


void push(char *x)
{
	printFnCallFlag && printf("\npush called\n");
	strcpy(s[++top].value,x);
}

void swap(char *x, char *y)
{
	printFnCallFlag && printf("\nswap called\n");
	char temp = *x;
	*x = *y;
	*y = temp;
}

void reverse(char str[], int length) 
{ 
	printFnCallFlag && printf("\nreverse called\n");
	int start = 0; 
	int end = length -1; 
	while (start < end) 
	{ 
		swap((str+start), (str+end)); 
		start++; 
		end--; 
	} 
} 
  
char* itoa(int num, char* str, int base) 
{ 
	printFnCallFlag && printf("\nitoa called\n");
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
  
	reverse(str, i); 
  
	return str; 
} 

void codegen()
{
	printFnCallFlag && printf("\ncodegen called\n");
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	// printf("%s = %s %s %s\n",temp,s[top-2].value,s[top-1].value,s[top].value);

	char instr[100];
	sprintf(instr, "%s = %s %s %s", temp, s[top-2].value, s[top-1].value, s[top].value);
	insert_icg(instr);
	top = top - 2;
	strcpy(s[top].value,temp);
	count++; 
}

void codegencon()
{
	printFnCallFlag && printf("\ncodegencon called\n");
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	// printf("%s = %s\n",temp,curval);
	// printf("%s = %s\n",curid,temp);

	char instr[100];
	sprintf(instr, "%s = %s", temp, curval);
	insert_icg(instr);
	sprintf(instr, "%s = %s", curid, temp);
	insert_icg(instr);

	push(temp);
	count++;
}

int isunary(char *s)
{
	printFnCallFlag && printf("\nisunary called\n");
	if(strcmp(s, "--")==0 || strcmp(s, "++")==0)
	{
		return 1;
	}
	return 0;
}

void genunary()
{
	printFnCallFlag && printf("\ngenunary called\n");
	char temp1[100], temp2[100], temp3[100];
	strcpy(temp1, s[top].value);
	strcpy(temp2, s[top-1].value);

	if(isunary(temp1))
	{
		strcpy(temp3, temp1);
		strcpy(temp1, temp2);
		strcpy(temp2, temp3);
	}
	strcpy(temp, "t");
	char buffer[100];
	itoa(count, buffer, 10);
	strcat(temp, buffer);
	count++;

	if(strcmp(temp2,"--")==0)
	{
		// printf("%s = %s - 1\n", temp, temp1);
		// printf("%s = %s\n", temp1, temp);

		char instr[100];
		sprintf(instr, "%s = %s - 1", temp, temp1);
		insert_icg(instr);
		sprintf(instr, "%s = %s", temp1, temp);
		insert_icg(instr);
	}

	if(strcmp(temp2,"++")==0)
	{
		// printf("%s = %s + 1\n", temp, temp1);
		// printf("%s = %s\n", temp1, temp);

		char instr[100];
		sprintf(instr, "%s = %s + 1", temp, temp1);
		insert_icg(instr);
		sprintf(instr, "%s = %s", temp1, temp);
		insert_icg(instr);
	}

	top = top -2;
}

void codeassign()
{
	printFnCallFlag && printf("\ncodeassign called\n");
	// printf("%s = %s\n",s[top-2].value,s[top].value);

	char instr[100];
	sprintf(instr, "%s = %s", s[top-2].value, s[top].value);
	insert_icg(instr);
	top = top - 2;
}

void label_start_conditional()
{
	printFnCallFlag && printf("\nlabel_start_conditional called\n");
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	// printf("IF not %s GoTo %s\n",s[top].value,temp);

	char instr[100];
	sprintf(instr, "IF not %s GoTo %s", s[top].value, temp);
	insert_icg(instr);
	label[++ltop].labelvalue = lno++;
}

void label_else_conditional()
{
	printFnCallFlag && printf("\nlabel_else_conditional called\n");
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	// printf("GoTo %s\n",temp);

	char instr[100];
	sprintf(instr, "GoTo %s", temp);
	insert_icg(instr);

	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	// printf("%s:\n",temp);

	sprintf(instr, "%s:", temp);
	insert_icg(instr);
	ltop--;
	label[++ltop].labelvalue=lno++;
}

void label_exit_conditional()
{
	printFnCallFlag && printf("\nlabel_exit_conditional called\n");
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	// printf("%s:\n",temp);

	char instr[100];
	sprintf(instr, "%s:", temp);
	insert_icg(instr);
	ltop--;
}

void label_loop_conditional()
{
	printFnCallFlag && printf("\nlabel_loop_conditional called\n");
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	// printf("%s:\n",temp);

	char instr[100];
	sprintf(instr, "%s:", temp);
	insert_icg(instr);

	label[++ltop].labelvalue = lno++;
}

void label_loop_end()
{
	printFnCallFlag && printf("\nlabel_loop_end called\n");
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop-1].labelvalue,buffer,10);
	strcat(temp,buffer);
	// printf("GoTo %s:\n",temp);

	char instr[100];
	sprintf(instr, "GoTo %s", temp);
	insert_icg(instr);

	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	// printf("%s:\n",temp);

	sprintf(instr, "%s:", temp);
	insert_icg(instr);
	ltop = ltop - 2;
}

void funcgen()
{
	printFnCallFlag && printf("\nfuncgen called\n");
	// printf("func begin %s\n",currfunc);

	char instr[100];
	sprintf(instr, "func begin %s", currfunc);
	insert_icg(instr);
}

void funcgenend()
{
	printFnCallFlag && printf("\nfuncgenend called\n");
	// printf("func end\n\n");

	char instr[100];
	sprintf(instr, "func end\n");
	insert_icg(instr);
}

void arggen(int i)
{
	printFnCallFlag && printf("\narggen called\n");
	if(i==1)
	{
		// printf("param %s\n", curid);

		char instr[100];
		sprintf(instr, "param %s", curid);
		insert_icg(instr);
	}
	else
	{
		// printf("param %s\n", curval);

		char instr[100];
		sprintf(instr, "param %s", curval);
		insert_icg(instr);
	}
}

void callgen()
{
	printFnCallFlag && printf("\ncallgen called\n");
	// printf("call %s, %d\n",currfunccall,call_params_count);

	char instr[100];
	sprintf(instr, "call %s, %d", currfunccall, call_params_count);
	insert_icg(instr);

}



int main(int argc , char **argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();

	if(flag == 0)
	{
		print_icg();
		printf( "PASSED: ICG Phase\n" );
		printf("%30s"  "PRINTING SYMBOL TABLE"  "\n", " ");
		printf("%30s %s\n", " ", "______________");
		printST();

		printf("\n\n%30s"  "PRINTING CONSTANT TABLE"  "\n", " ");
		printf("%30s %s\n", " ", "______________");
		printCT();
	}
}

void yyerror(char *s)
{
	printf( "Line %d : %s %s\n", yylineno, s, yytext);
	flag=1;
	printf( "FAILED: ICG Phase Parsing failed\n" );
	exit(7);
}

void ins()
{
	insertSTtype(curid,curtype);
}

void insV()
{
	insertSTvalue(curid,curval);
}

int yywrap()
{
	return 1;
}