%{
/* Declarations section */
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using std::cout;
using std::endl;
void showToken(const char * name);
%}

%option yylineno
%option noyywrap

digit           ([0-9])
letter          ([a-zA-Z])
bin             ([0-1])
oct             ([0-7])
hex             ([a-f0-9])
real            ({digit}\.{digit}*|{digit}*\.{digit})
expo            ({e-|e+|E-|E+})
fp              ({p-|p+|P-|P+})
whitespace      ([\r\t\n ])
relop           ((==)|(!=)|(<=)|(>=)|(<)|(>))
logop           ((&&)|(||))
binop           ([%-+*/])

%%
"Int"|"UInt"|"Double"|"Float"|"Bool"|"String"|"Character"	showToken("TYPE");
"var"                                                     showToken("VAR");
"let"                                                showToken("LET");
"func"                                               showToken("FUNC");
"import"                                             showToken("IMPORT");
"nil"                                                showToken ("NIL");
"while"                                              showToken("WHILE");
"if"                                                 showToken("IF");
"else"                                               showToken("ELSE");
"return"                                             showToken("RETURN");
";"                                                  showToken("SC");
","                                                  showToken("COMMA");
"("                                                  showToken("LPAREN");
")"                                                  showToken("RPAREN");
"{"                                                  showToken("LBRACE");
"}"                                                  showToken("RBRACE");
"["                                                  showToken("LBRACKET");
"]"                                                  showToken("RBRACKET");
"="                                                  showToken("ASSIGN");
{relop}                                              showToken("RELOP");
{logop}                                              showToken("LOGOP");
{binop}                                              showToken("BINOP");
"true"                                               showToken("TRUE");
"false"                                              showToken("FALSE");
"->"	                                               showToken("ARROW");
":"	                                                 showToken("COLON");

{{letter}[a-zA-Z0-9]*|_[a-zA-Z0-9]+}                 showToken("ID");
{0b{bin}+}	                                         showToken("BIN_INT");
{0o{oct}+}	                                         showToken("OCT_INT");
{digit}+	                                           showToken("DEC_INT");
{0x{hex}+}	                                         showToken("HEX_INT");
{real}|{real}{expo}{digit}	                         showToken("DEC_REAL");
{0x{hex}+{fp}{digit}}	                               showToken("HEX_FP");
"\/\*"[^"\/\*"]"\/\*"                                showToken("COMMENT");
"\/\/"[^\n\r]*                                       showToken("COMMENT");
\"(\\.|[^\"\n\r])*\"                                 showToken("STRING");
{whitespace}                                         ;
.  printf("Error %s\n",yytext);exit(0);
%%

void showToken(const char * name){
	cout<< yylineno<< " " << name << " " << yytext << endl;
}
