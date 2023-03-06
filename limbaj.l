%{
#include "y.tab.h"
#include "string.h"
#include <stdlib.h>
#include <stdio.h>
%}

%option noyywrap

%%

"START_USER_DEFINED_TYPES"                  {return START_USR_DEFINED_TYPES;}
"END_USER_DEFINED_TYPES"                    {return END_USR_DEFINED_TYPES;}

"START_GLOBAL_DECLARATIONS"                 {return START_GLOBAL_DECLARATIONS;}
"END_GLOBAL_DECLARATIONS"                   {return END_GLOBAL_DECLARATIONS;}

"START_FUNCTION_DECLARATIONS"                {return START_FUNCTION_DECLARATIONS;}
"END_FUNCTION_DECLARATIONS"                  {return END_FUNCTION_DECLARATIONS;} 

"START_MAIN"                                {return START_MAIN;}
"END_MAIN"                                  {return END_MAIN;}

"void"                                      {return VOID_TYPE;}
"int"                                       {return INT_TYPE;}
"float"                                     {return FLOAT_TYPE;}
"char"                                      {return CHAR_TYPE;}
"string"                                    {return STRING_TYPE;}
"bool"                                      {return BOOL_TYPE;}
"const"                                     {return CONST_KEYWORD;}

"my_type"                                   {return  STRUCT_TYPE;}
"::"                                        {return  STRUCT_MEMBER_ACCESS;}

"{"                                         {return OPEN_CURLY_PAR;}
"}"                                         {return CLOSE_CURLY_PAR;}
"("                                         {return OPEN_PAR;}
")"                                         {return CLOSE_PAR;}

";"                                         {return SEMICOLON;}
","                                         {return COMMA;}
"="                                         {return ASSIGN;}
"+'"                                         {return PLUS;}
"-'"                                         {return MINUS;}
"*'"                                         {return MULTIPLY;}
"/'"                                         {return DIVIDE;}
"%'"                                         {return MODULO;}

"if"                                        {return IF;}
"else"                                      {return ELSE;}
"for"                                       {return FOR;}
"while"                                     {return WHILE;}
"do"                                        {return DO;}
"return"                                    {return RETURN;}

"Eval"                                      {return EVAL_PREDEFINED;}   /* Eval(arg) where arg is an arithmetic expression, variable or number */
"TypeOf"                                    {return TYPEOF_PREDEFINED;} /* TypeOf(arg)*/    

"&&"                                        {return AND;}
"||"                                        {return OR;}
"!"                                         {return NOT;}
"=="                                        {return EQ;}
"!="                                        {return NE;}
"<"                                         {return LT;}
">"                                         {return GT;}
"<="                                        {return LE;}
">="                                        {return GE;}



0u|[1-9][0-9]*u                             {yytext[strlen(yytext)-1] = '\0';   yylval.unsigned_value = atoi(yytext);  return UNSIGNED_LITERAL;}
0|([-+]?([1-9][0-9]*))                      {yylval.int_value = atoi(yytext);       return INT_LITERAL;}
[-+]?([0]?\.[0-9]+|[1-9][0-9]*\.[0-9]+)     {yylval.float_value = atof(yytext);     return FLOAT_LITERAL;}
\'.\'                                       {yylval.char_value = yytext[1];         return CHAR_LITERAL;}
\".*\"                                      {yylval.string_value = strdup(yytext);  return STRING_LITERAL;}
"true"                                      {yylval.bool_value = 1;                 return BOOL_LITERAL;}
"false"                                     {yylval.bool_value = 0;                 return BOOL_LITERAL;}

@[_a-zA-Z][_a-zA-Z0-9]*                     {yylval.string_value = strdup(yytext);  return IDENTIFIER_VARIABLE;}
$[_a-zA-Z][_a-zA-Z0-9]*                     {yylval.string_value = strdup(yytext);  return IDENTIFIER_FUNCTION;}
#[_a-zA-Z][_a-zA-Z0-9]*                     {yylval.string_value = strdup(yytext);  return IDENTIFIER_STRUCT;}


\n                                          { yylineno += 1;/*printf("%s -> linia %d\n",yytext,yylineno);*/ }
[ \t]                                       { ; }
.                                           { return yytext[0];}
%%