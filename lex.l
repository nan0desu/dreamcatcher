%{
	#include "parse.tab.h"

	int current_depth = 0;
	int brace_depth = 0;
	int last_depth = 0;
%}

%x REGULAR
%x COMMENT
%x MULTICOMMENT
%x STRING_STATE
%x MULTISTRING

%%

<*><<EOF>>		{
				if(last_depth > 0) {last_depth--; return DEDENT;}
				yyterminate();
			}
			
^[\t ]*			{current_depth+=yyleng;}
			
[^\t\n ]		{
				yyless(0);
				if(current_depth > last_depth) {BEGIN REGULAR; return INDENT;}
				if(current_depth < last_depth) {last_depth--; return DEDENT;}
				BEGIN REGULAR;
			}
			
\n			{current_depth = 0;}

<REGULAR>\\(.|\n)		{; /* Escapes */}

<REGULAR>\n			{last_depth = current_depth; current_depth = 0; BEGIN INITIAL; return NEWLINE; /* newline */}

%{/* Comments */%}
<REGULAR>\/\/			{BEGIN COMMENT;}
<COMMENT>\n			{BEGIN REGULAR; yyless(0);}
<COMMENT>.			{;}

<REGULAR>\/\*			{BEGIN MULTICOMMENT;}
<MULTICOMMENT>\\(.|\n)		{;}
<MULTICOMMENT>\*\/		{BEGIN REGULAR;}
<MULTICOMMENT>.|\n		{;}

%{/* Strings */%}
<REGULAR>\"			{BEGIN STRING_STATE;}
<STRING_STATE>\n		{BEGIN REGULAR; yyless(0); return STRING;}
<STRING_STATE>\\(.|\n)		{;}
<STRING_STATE>\"		{BEGIN REGULAR; return STRING;}
<STRING_STATE>.			{;}

<REGULAR>\{\"			{BEGIN MULTISTRING;}
<MULTISTRING>\\(.|\n)		{;}
<MULTISTRING>\"\}		{BEGIN REGULAR; return STRING;}
<MULTISTRING>.|\n		{;}

%{/* Keywords */%}
<REGULAR>var			{return VAR;}
<REGULAR>proc|verb		{return PROC;}

%{/* Operators */%}
<REGULAR>"="			|
<REGULAR>"+"			|
<REGULAR>"-"			|
<REGULAR>"*"			|
<REGULAR>"/"			|
<REGULAR>"("			|
<REGULAR>")"			{return yytext[0];}

<REGULAR>[_a-zA-Z][_0-9a-zA-Z]*	{yylval.name = strdup(yytext); return IDENTIFIER; /* Identifiers */}

<REGULAR>[1-9][0-9]*		{return NUMBER;}
<REGULAR>[1-9][0-9]*\.[0-9]+	{return NUMBER;}

%{/* Dump extraneous space */%}
<REGULAR>[ \t]+			{;}


%%

int yyerror() {printf("Error\n");}
