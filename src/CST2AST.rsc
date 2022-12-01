module CST2AST

import Syntax;
import AST;

import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  return cst2ast(sf.top); // remove layout before and after form
}

AForm cst2ast(form:(Form)`form <Id name> { <Question* questions> }`) {
  return form(cst2ast(name), [cst2ast(q) | q <- questions], src = form.src);
}

AQuestion cst2ast(q:(Question)`<Id text> <Id var> : <Type datatype>`) {
  return question(cst2ast(text), cst2ast(var), cst2ast(datatype), src = q.src);
}

AQuestion cst2ast(q:(Question)`<Id text> <Id var> : <Type datatype> = <Expr expr>`) {
  return question(cst2ast(text), cst2ast(var), cst2ast(datatype), cst2ast(expr), src = q.src);
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
    case (Type)`boolean`: return Bool;
    case (Type)`integer`: return Int;
    case (Type)`string`: return Str;
    default: throw "Unhandled type: <t>";
  }
}

AId cst2ast(Id i) {
  return id("<i>", src=i.src);
}
