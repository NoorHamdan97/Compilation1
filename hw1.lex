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

digit [0-9]
letter [a-zA-Z]
bin [0-1]
oct [0-7]
hex [a-f0-9]
real {digit}\.{digit}*|{digit}*\.{digit}
expo {e-|e+|E-|E+}
fp {p-|p+|P-|P+}
whitespace [\r\t\n ]
relop ((==)|(!=)|(<=)|(>=)|(<)|(>))
logop ((&&)|(||))
binop [%-+*/]

%%
"Int"|"UInt"|"Double"|"Float"|"Bool"|"String"|"Character"	return showToken("TYPE");
"var" return showToken("VAR");
"let" return showToken("LET");
"func" return showToken("FUNC");
"import" return showToken("IMPORT");
"nil" return showToken("NIL");
"true" return showToken("TRUE");
"false" return showToken("FALSE");
"->"	return showToken("ARROW");
":"	return showToken("COLON");
"return" return showToken("RETURN");
"if" return showToken("IF");
"else" return showToken("ELSE");
"while" return showToken("WHILE");
";" return showToken("SC");
"," return showToken("COMMA");
"(" return showToken("LPAREN");
")" return showToken("RPAREN");
"{" return showToken("LBRACE");
"}" return showToken("RBRACE");
"[" return showToken("LBRACKET");
"]" return showToken("RBRACKET");
"=" return showToken("ASSIGN");
{relop} return showToken("RELOP");
{logop} return showToken("LOGOP");
{binop} return showToken("BINOP");
{{letter}[a-zA-Z0-9]*|_[a-zA-Z0-9]+} return showToken("ID");
{0b{bin}+}	return showToken("BIN_INT");
{0o{oct}+}	return showToken("OCT_INT");
{digit}	return showToken("DEC_INT");
{0x{hex}+}	return showToken("HEX_INT");
{real}|{real}{expo}{digit}	return showToken("DEC_REAL");
{0x{hex}+{fp}{digit}}	return showToken("HEX_FP");
"\/\*"[^"\/\*"]"\/\*" return showToken("COMMENT");
"\/\/"[^\n\r]* return showToken("COMMENT");

\"(\\.|[^\"\n\r])*\" return showToken("STRING");

{whitespace} ;
. printf("Error %s\n",yytext);exit(0);
%%

void showToken(const char * name){
	cout<< yylineno<< " " << name << " " << yytext << endl;
}
