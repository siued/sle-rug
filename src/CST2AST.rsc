module CST2AST

import Syntax;
import AST;
import String;

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

AForm cst2ast(f:(Form)`form <Id name> { <Question* questions> }`) {
  return form(cst2ast(name), [cst2ast(q) | Question q <- questions], src = f.src);
}

AQuestion cst2ast(Question q) {
  switch (q) {
    case (Question)`<Str text> <Id var> : <Type datatype>` :
      return question(cst2ast(text), cst2ast(var), cst2ast(datatype), src = q.src);
    
    case (Question)`<Str text> <Id var> : <Type datatype> = <Expr expr>` :
      return question(cst2ast(text), cst2ast(var), cst2ast(datatype), cst2ast(expr), src = q.src);
    
    case (Question)`if ( <Expr e> ) { <Question* questions> }`:
      return ifstatement(cst2ast(e), [cst2ast(q) | Question q <- questions]);
    
    case (Question)`if ( <Expr e> ) { <Question* questions> } else { <Question* questions2> }`:
      return ifelsestatement(cst2ast(e), [cst2ast(q) | Question q <- questions], [cst2ast(q) | Question q <- questions2]);

    default:
      throw "failed";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return datavar(cst2ast(x), src=x.src);
    case (Expr)`<Int i>`: return datavar(toInt("<i>"), src=i.src);
    case (Expr)`<Bool b>`: return datavar("<b>", src=b.src);
    case (Expr)`( <Expr e> )`: return cst2ast(e);
    case (Expr)`! <Expr e>`: return not(cst2ast(e), src=e.src);
    case (Expr)`<Expr e1> * <Expr e2>`: return mul(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> / <Expr e2>`: return div(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> + <Expr e2>`: return add(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> - <Expr e2>`: return sub(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \< <Expr e2>`: return lessthan(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \> <Expr e2>`: return greaterthan(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \<= <Expr e2>`: return lessthanequal(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \>= <Expr e2>`: return greaterthanequal(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> == <Expr e2>`: return equal(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> != <Expr e2>`: return notequal(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> && <Expr e2>`: return and(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> || <Expr e2>`: return or(cst2ast(e1), cst2ast(e2), src=e.src);
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
    case (Type)`boolean`: return booleanType();
    case (Type)`integer`: return integerType();
    case (Type)`string`: return stringType();

    default: throw "Unhandled type: <t>";
  }
}

AStr cst2ast(Str name) {
  return string("<name>", src=name.src);
}

AId cst2ast(Id i) {
  return id("<i>", src=i.src);
}
