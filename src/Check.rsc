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

  for (/question(AStr label, AId var, AType vartype) := f) {
    tenv += {<var.src, var.name, label.name, typeOf(vartype)>};
  }

  for (/question(AStr label, AId var, AType vartype, _) := f) {
    tenv += {<var.src, var.name, label.name, typeOf(vartype)>};
  }
  
  return tenv;
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
    case question(string(label, src = label_src), id(str var, src = loc var_src), AType datatype, src = loc l):
    // check for duplicate labels
    {
      msgs += { warning("Different variable names for same label", label_src) 
        | <loc other_var_src, str other_var, label, Type t> <- tenv,
        other_var_src != var_src, 
        typeOf(datatype) != t || other_var != var};
      
      // check for type mismatch
      msgs += { error("Variable already declared with a different type", var_src) 
      | <_, var, _, Type t> <- tenv,
      typeOf(datatype) != t};

      msgs += {warning("Different label for same variable name", label_src)
        | <_, var, str other_label, _> <- tenv,
        label != other_label};
    }
      
      
    case question(string(label, src = label_src), id(var, src = var_src), AType datatype, AExpr expr):
      // check for duplicate labels
    {
      
      msgs += { warning("Different variable names for same label", label_src) 
        | <loc other_var_src, str other_var, label, Type t> <- tenv,
        other_var_src != var_src, 
        typeOf(datatype) != t || other_var != var};
      
      // check for type mismatch
      msgs += { error("Variable already declared with a different type", var_src) 
        | <_, var, _, Type t> <- tenv,
        typeOf(datatype) != t};
    

      // checking for type realocation
      msgs += { error("Variable and expression have incompatible types", var_src)
        | typeOf(datatype) != typeOf(expr, tenv, useDef)};

      msgs += {warning("Different label for same variable name", label_src)
        | <_, var, str other_label, _> <- tenv,
        label != other_label};
      
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
      msgs += { error("Undeclared variable", x.src) | useDef[x.src] == {} };

    case add(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Addition requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case mul(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Multiplication requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}


    case div(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Division requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case sub(AExpr lhs, AExpr rhs, src = loc l): 
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Subtraction requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case lessthan(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less-than requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case greaterthan(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater-than requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case lessthanequal(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less-than-or-equal requires integer operands", l) };
      } 
      msgs += check(lhs, rhs, tenv, useDef);}
    
    case greaterthanequal(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater-than-or-equal requires integer operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case equal(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
        msgs += { error("Equality requires operands of the same type", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case notequal(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
        msgs += { error("Inequality requires operands of the same type", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case and(AExpr lhs, AExpr rhs, src = loc l):
      {if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("AND requires boolean operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case or(AExpr lhs, AExpr rhs, src = loc l): 
      {if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("OR requires boolean operands", l) };
      }
      msgs += check(lhs, rhs, tenv, useDef);}

    case not(AExpr e, src = loc l):
      {
        if (typeOf(e, tenv, useDef) != tbool()) {
          msgs += { error("NOT requires a boolean operand", l) };
        }
        msgs += check(e, tenv, useDef);
      }
  }
  
  return msgs; 
}

set[Message] check(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef) {
  return check(lhs, tenv, useDef) + check(rhs, tenv, useDef);
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case datavar(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
        return t;
      }
    case datavar(ABool b): return tbool();
    case datavar(int x): return tint();
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

Type typeOf(AType t) = typeOf(t, {}, {});

Type typeOf(AType t, _, _) {
  switch (t) {
    case booleanType(): return tbool();
    case integerType(): return tint();
    case stringType(): return tstr();
  }
  return tunknown();
}
 
default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();