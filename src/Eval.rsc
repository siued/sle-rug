module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv venv = ();
  for (/question(_, id(str var), AType t) := f) {
    switch (t) {
      case integerType(): venv[var] = vint(0);
      case booleanType(): venv[var] = vbool(false);
      case stringType(): venv[var] = vstr("");
      default: throw "Unsupported type <t>";
    }
  }
  
  for (/question(_, id(str var), AType t, AExpr e) := f) {
    switch (t) {
      case integerType(): venv[var] = vint(0);
      case booleanType(): venv[var] = vbool(false);
      case stringType(): venv[var] = vstr("");
      default: throw "Unsupported type <t>";
    }
  }
  return venv;
}


// Because of out of order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  venv[inp.question] = inp.\value;
  // for (str s := venv) {
  //   venv[s] = eval(expr, venv) where (/question(_, id(str s), _, AExpr expr) := f);
  // }
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv

  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case datavar(id(str x)) : return venv[x];
    case datavar(boolean(str val)) : return vbool(val == "<true>");
    case datavar(int i) : return vint(i);
    case not(AExpr e): return vbool(!eval(e, venv).b);
    case mul(AExpr e1, AExpr e2): return vint(eval(e1, venv).n * eval(e2, venv).n);
    case div(AExpr e1, AExpr e2): return vint(eval(e1, venv).n / eval(e2, venv).n);
    case add(AExpr e1, AExpr e2): return vint(eval(e1, venv).n + eval(e2, venv).n);
    case sub(AExpr e1, AExpr e2): return vint(eval(e1, venv).n - eval(e2, venv).n);
    case lessthan(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n < eval(e2, venv).n);
    case greaterthan(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n > eval(e2, venv).n);
    case lessthanequal(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n <= eval(e2, venv).n);
    case greaterthanequal(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n >= eval(e2, venv).n);
    case equal(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n == eval(e2, venv).n);
    case notequal(AExpr e1, AExpr e2): return vbool(eval(e1, venv).n != eval(e2, venv).n);
    case and(AExpr e1, AExpr e2): return vbool(eval(e1, venv).b && eval(e2, venv).b);
    case or(AExpr e1, AExpr e2): return vbool(eval(e1, venv).b || eval(e2, venv).b);

    default: throw "Unsupported expression <e>";
  }
}
