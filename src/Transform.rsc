module Transform

import Syntax;
import Resolve;
import AST;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  AExpr e = datavar(boolean("true"));
  list[AQuestion] flattened = [];
  flattened += flatten(f.questions, e);
  return form(f.name, flattened); 
}

list[AQuestion] flatten(list[AQuestion] questions, AExpr e) {
  list[AQuestion] flattened = [];
  for (AQuestion q <- questions) {
    switch(q) {
      case question(_, _, _):
        flattened += ifstatement(e, [q]);
      case question(_, _, _, _):
        flattened += ifstatement(e, [q]);
      case ifstatement(e1, qs):
        flattened += flatten(qs, and(e, e1));
      case ifelsestatement(e1, qs1, qs2):
      {
        flattened += flatten(qs1, and(e, e1));
        flattened += flatten(qs2, and(e, not(e1)));
      }
    }
  }
  return flattened;
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  str name = useOrDef;
   return f; 
} 
 
 
 

