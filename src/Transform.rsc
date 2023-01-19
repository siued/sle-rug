module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import ParseTree;
import IO;

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
 
start[Form] rename(start[Form] f, loc name, str newName) {
  RefGraph r = resolve(cst2ast(f));
  set[loc] toRename = {};
  if(name in r.defs<1>) {
    toRename += {name};
    toRename += { u | <loc u, name> <- r.useDef};
  } else if (name in r.uses<0>) {
      if (<name, loc d> <- r.useDef) {
        toRename += {d};
        toRename += { u | <loc u, d> <- r.useDef};
      } 
  } else {
        return f;
  }
  return visit (f) {
    case Id variable => [Id]newName when variable@\loc in toRename
  };
} 

 
 
 

