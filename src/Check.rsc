module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};

  for (/question(AStr label, AId var, AType vartype, src = loc d) := f) {
    tenv += {<d, var.name, label.name, convert(vartype)>};
  }

  for (/question(AStr label, AId var, AType vartype, _, src = loc d) := f) {
    tenv += {<d, var.name, label.name, convert(vartype)>};
  }
  
  return tenv;
}

Type convert(AType datatype) {
  switch (datatype) {
    case integerType(): return tint();
    case booleanType(): return tbool();
    case stringType(): return tstr();
    default: return tunknown();
  }
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  for (AQuestion q <- f.questions) {
    msgs += check (q, tenv, useDef);
  }
  return msgs;
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (q) {
    case question(string(str text), id(str varname), AType datatype, src = loc l):
      // check for duplicate labels
      {
          msgs += { warning("Duplicate label", l) 
        | <loc l2, _, text, _> <- tenv, 
        <loc l3, _, text, _> <- tenv, 
        l2 != l3
        };
        
        // check for type mismatch
        msgs += { error("Variable already declared with a different type", l) 
        | <loc l2, str varname, text, Type vartype> <- tenv,
        convert(datatype) != vartype};
      }
      
      
    case question(string(text), id(variable), AType datatype, AExpr expr, src = loc l):
      // check for duplicate labels
      {
        
        msgs += { warning("Duplicate label", l) 
          |  <loc l2, str varname, text, Type vartype> <- tenv, 
            l != l2
          };
        
        // check for type mismatch
          msgs += { error("Variable already declared with a different type", variable.src) 
            | <loc l2, str varname, text, Type vartype> <- tenv,
            convert(datatype) != vartype};
      

        // checking for type realocation
        msgs += { error("Variable already declared with a different type", variable.src)
          | <_, variable, _, Type t> <- tenv, typeOf(datatype, tenv, useDef) != t };
        
        msgs += check(expr, tenv, useDef);
      }

    case ifstatement(AExpr expr, list[AQuestion] questions):
    {
      if (typeOf(expr, tenv, useDef) != tbool()) {
        msgs += { error("If statement requires boolean expression", expr.src) };
      }
      for (AQuestion q <- questions) {
        msgs += check(q, tenv, useDef);
      }
      msgs += check(expr, tenv, useDef);
    }
    
    case ifelsestatement(AExpr expr, list[AQuestion] questions, list[AQuestion] elsequestions):
    {
      if (typeOf(expr, tenv, useDef) != tbool()) {
        msgs += { error("If statement requires boolean expression", expr.src) };
      }
      for (AQuestion q <- questions) {
        msgs += check(q, tenv, useDef);
      }
      for (AQuestion q <- elsequestions) {
        msgs += check(q, tenv, useDef);
      }
      msgs += check(expr, tenv, useDef);
    }
      
  }
  return msgs;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case datavar(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    case add(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Addition requires integer operands", e.src) };
      }

    case mul(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Multiplication requires integer operands", e.src) };
      }

    case div(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Division requires integer operands", e.src) };
      }

    case sub(AExpr lhs, AExpr rhs): 
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Subtraction requires integer operands", e.src) };
      }

    case lessthan(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less-than requires integer operands", e.src) };
      }

    case greaterthan(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater-than requires integer operands", e.src) };
      }

    case lessthanequal(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less-than-or-equal requires integer operands", e.src) };
      } 
    
    case greaterthanequal(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater-than-or-equal requires integer operands", e.src) };
      }

    case equal(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
        msgs += { error("Equality requires operands of the same type", e.src) };
      }

    case notequal(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
        msgs += { error("Inequality requires operands of the same type", e.src) };
      }

    case and(AExpr lhs, AExpr rhs):
      if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("And requires boolean operands", e.src) };
      }

    case or(AExpr lhs, AExpr rhs): 
      if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("Or requires boolean operands", e.src) };
      }
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case datavar(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
        return t;
      }
    case datavar(_): return tbool();
    case datavar(_): return tint();
    case not(_): return tbool();
    case add(_, _): return tint();
    case mul(_, _): return tint();
    case div(_, _): return tint();
    case sub(_, _): return tint();
    case lessthan(_, _): return tbool();
    case greaterthan(_, _): return tbool();
    case lessthanequal(_, _): return tbool();
    case greaterthanequal(_, _): return tbool();
    case equal(_, _): return tbool();
    case notequal(_, _): return tbool();
    case and(_, _): return tbool();
    case or(_, _): return tbool();
  }
  return tunknown(); 
}

Type typeOf(AType t, TEnv tenv, UseDef useDef) {
  switch (t) {
    case booleanType(): return tbool();
    case integerType(): return tint();
    case stringType(): return tstr();
  }
  return tunknown();
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */


Type typeOf(datavar(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
  when <u, loc d> <- useDef, <d, _, _, Type t> <- tenv;
 
default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();