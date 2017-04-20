/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */ 
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/ 

/********************************************************************************/
/* This file is used to generate a rule checker for COM.INST.LoopCondition rule.*/
/* For further information on this, we advise you to refer to RNC manuals.	    */
/* As many comments have been done on the ExampleRule.lex file, this file       */
/* will restrain its comments on modifications.								    */
/*																			    */
/********************************************************************************/

package fr.cnes.analysis.tools.fortran90.rules;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.List;

import org.eclipse.core.runtime.IPath;

import fr.cnes.analysis.tools.analyzer.datas.AbstractRule;
import fr.cnes.analysis.tools.analyzer.datas.Violation;
import fr.cnes.analysis.tools.analyzer.exception.JFlexException;

%%

%class COMINSTLoopCondition
%extends AbstractRule
%public
%line
%ignorecase

%function run
%yylexthrow JFlexException
%type List<Violation>


%state COMMENT, NAMING, NEW_LINE, LINE, LOOP

COMMENT_WORD = \!         | c          | C     | \*
FREE_COMMENT = \!
FUNC         = FUNCTION   | function
PROC         = PROCEDURE  | procedure
SUB          = SUBROUTINE | subroutine
PROG         = PROGRAM    | program
MOD          = MODULE     | module
TYPE		 = {FUNC}     | {PROC}	   | {SUB} | {PROG} | {MOD}
WHILE		 = WHILE	  | while
WHILE_LOOP	 = {WHILE} [\ ]* \(
			   
EQUAL		 = ".EQ."		| \=		| \=\=
DIFF		 = ".NE."		| \!\=	
COND_ERROR	 = {EQUAL}		| {DIFF}
INEG		 = 	\<			| \>		| \<\=		| \>\=		|
			    ".LT."		| ".GT."	| ".LE."	| ".GE." 

VAR		     = [a-zA-Z][a-zA-Z0-9\_]*

																
%{
	String location = "MAIN PROGRAM";
	int par = 0;
	
	public COMINSTLoopCondition(){
	}
	
	@Override
	public void setInputFile(IPath file) throws FileNotFoundException {
		super.setInputFile(file);
		this.zzReader = new FileReader(file.toOSString());
	}
	
	

	
%}

%eofval{
    return getViolations();
%eofval}


%%          

/************************/

				{FREE_COMMENT}	{yybegin(COMMENT);}

/************************/
/* COMMENT STATE	    */
/************************/
<COMMENT>   	\n             	{yybegin(NEW_LINE);}  
<COMMENT>   	.              	{}


/************************/
/* NAMING STATE	        */
/************************/
<NAMING>		{VAR}			{location = location + " " + yytext(); yybegin(COMMENT);}
<NAMING>    	\n             	{yybegin(NEW_LINE);}
<NAMING>    	.              	{}


/************************/
/* YYINITIAL STATE	    */
/************************/
<YYINITIAL>  	{COMMENT_WORD} 	{yybegin(COMMENT);}
<YYINITIAL>		{TYPE}        	{location = yytext(); yybegin(NAMING);}
<YYINITIAL> 	\n             	{yybegin(NEW_LINE);}
<YYINITIAL> 	.              	{yybegin(LINE);}


/************************/
/* NEW_LINE STATE	    */
/************************/
<NEW_LINE>  	{COMMENT_WORD} 	{yybegin(COMMENT);}
<NEW_LINE>		{TYPE}        	{location = yytext(); yybegin(NAMING);}
<NEW_LINE>		{WHILE_LOOP}	{par=1; yybegin(LOOP);}
<NEW_LINE>  	\n             	{}
<NEW_LINE>  	.              	{yybegin(LINE);}


/************************/
/* LINE STATE    	    */
/************************/
<LINE>			{TYPE}        	{location = yytext(); yybegin(NAMING);}
<LINE>			{WHILE_LOOP}	{par=1; yybegin(LOOP);}
<LINE>      	\n             	{yybegin(NEW_LINE);}
<LINE>      	.              	{}


/************************/
/* LOOP STATE    	    */
/************************/
<LOOP>			\(		 	 	{par++;}
<LOOP>			\)				{par--; if(par==0) yybegin(LINE);}
<LOOP>          {INEG}          {}
<LOOP>			{COND_ERROR}	{setError(location,"A loop condition shall not be written with equality or difference (==,!=).", yyline+1);
								yybegin(LINE);}
<LOOP>      	\n              {}
<LOOP>      	.              	{}


/************************/
/* ERROR STATE	        */
/************************/
				[^]           {throw new JFlexException( new Exception("Illegal character <" + yytext() + "> at line "+yyline+1) );}