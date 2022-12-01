module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = @Foldable "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question 
  = Str question Id variable ":" Type type
  | Str question Id variable ":" Type type "=" Expr expr
  | @Foldable "if" "(" Expr condition ")" "{" Question* thenQuestions "}"
  | @Foldable "if" "(" Expr condition ")" "{" Question* thenQuestions "}" "else" "{" Question* elseQuestions "}";

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr
  = Bool
  | Int
  | Id \ "true" \ "false" // true/false are reserved keywords.
  | "(" Expr ")"
  > right "!" Expr
  > left Expr "*" Expr
  | left Expr "/" Expr
  > left Expr "+" Expr
  | left Expr "-" Expr
  > non-assoc Expr "\<" Expr
  | non-assoc Expr "\>" Expr
  | non-assoc Expr "\>=" Expr
  | non-assoc Expr "\<=" Expr
  > non-assoc Expr "==" Expr
  | non-assoc Expr "!=" Expr
  > left Expr "&&" Expr
  > left Expr "||" Expr;
  
syntax Type = "boolean" | "integer" | "string";

lexical Str = "\""[a-zA-Z_\-0-9\ ]+":"?"?"?"\"";

lexical Int = [0-9]+;

lexical Bool = "true" | "false";