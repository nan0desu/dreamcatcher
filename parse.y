%token INDENT DEDENT IDENTIFIER VAR PROC OPERATOR IN EXPONENT EQUAL LSHIFT RSHIFT INCREMENT DECREMENT LAND LOR LEQUAL GEQUAL NEQUAL STRING AS NEWLINE NUMBER

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc '(' ')'

%union {
	char* name;
}

%type <name> IDENTIFIER;

%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

struct Typelist {
	void* contents;
	void* next;
} typedef Typelist;

struct Type {
	char* name;
	Typelist* children;
	void* parent;
} typedef Type;

Type root;
Type* current;

Type* addType(char* name) {
	Type* ret = malloc(sizeof(Type));
	ret->name = name;
	ret->children = NULL;
	ret->parent = current;
	
	if(current->children == NULL) {
		current->children = malloc(sizeof(Typelist));
		current->children->next = NULL;
		current->children->contents = ret;
	} else {
	
		Typelist* it = current->children;
		while(it->next != NULL)
		{
			it = (Typelist*) it->next;
		}
	
		it->next = malloc(sizeof(Typelist));
		it = (Typelist*) it->next;
		it->next = NULL;
		it->contents = ret;
	}
	
	return ret;
};

void printTypes(Type* base, int depth) {
	int i = 0;
	for(i = 0; i < depth; i++) {printf("\t");}
	printf("%s\n", base->name);
	
	Typelist* it = base->children;
	while(it != NULL) {
		printTypes((Type*) it->contents, depth + 1);
		it = (Typelist*) it->next;
	}
}

%}

%%

definitions: definition definitions | vardef definitions |

vardef: var_start newlines INDENT variables DEDENT	{current = (Type*) current->parent;}
	| var_start '/' variable			{current = (Type*) current->parent;}

defname: IDENTIFIER					{current = addType($1);}

definition: defname newlines definition_contents	{current = (Type*) current->parent;}
		| defname '/' definition 		{current = (Type*) current->parent;}
		| defname '/' vardef			{current = (Type*) current->parent;}
		
definition_contents: INDENT definitions DEDENT opt_newlines
		|
		
var_start: VAR						{current = addType("var");}

variables: variable variables |

varname: IDENTIFIER					{current = addType($1);}
variable: varname newlines variable_contents 		{current = (Type*) current->parent;}
		| varname '/' variable 			{current = (Type*) current->parent;}
		| varname '=' const_expression newlines	{current = (Type*) current->parent;}
		
variable_contents: INDENT variables DEDENT |

const_expression: NUMBER | STRING | '(' const_expression ')' |
		const_expression '+' const_expression |
		const_expression '-' const_expression |
		const_expression '*' const_expression |
		const_expression '/' const_expression |
		'-' const_expression %prec UMINUS
		
opt_newlines : newlines |		
newlines: NEWLINE newlines | NEWLINE

%%

#include <stdio.h>

int main() {
	current = &root;
	current->name = "root";
	current->children = NULL;
	current->parent = current;
	yyparse();
	
	printTypes(&root, 0);
}


