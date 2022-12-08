module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AId name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(AStr text, AId variable, AType datatype)
  | question(AStr text, AId variable, AType datatype, AExpr expr)
  | ifstatement(AExpr expr, list[AQuestion] questions)
  | ifelsestatement(AExpr expr, list[AQuestion] ifquestions, list[AQuestion] elsequestions)
  ; 

data AExpr(loc src = |tmp:///|)
  = datavar(ABool bx)
  | datavar(int ix)
  | datavar(AId sx)
  | not(AExpr expr1)
  | mul(AExpr expr1, AExpr expr2)
  | div(AExpr expr1, AExpr expr2)
  | add(AExpr expr1, AExpr expr2)
  | sub(AExpr expr1, AExpr expr2)
  | lessthan(AExpr expr1, AExpr expr2)
  | greaterthan(AExpr expr1, AExpr expr2)
  | lessthanequal(AExpr expr1, AExpr expr2)
  | greaterthanequal(AExpr expr1, AExpr expr2)
  | equal(AExpr expr1, AExpr expr2)
  | notequal(AExpr expr1, AExpr expr2)
  | and(AExpr expr1, AExpr expr2)
  | or(AExpr expr1, AExpr expr2)
  ;

data AType(loc src = |tmp:///|)
  = booleanType()
  | integerType()
  | stringType()
  ;

data AStr(loc src = |tmp:///|)
  = string(str name);

data AId(loc src = |tmp:///|)
  = id(str name);

data ABool(loc src = |tmp:///|)
  = boolean(str val);