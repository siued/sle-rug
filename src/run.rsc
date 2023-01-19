module run

import ParseTree;
import AST;
import Syntax;
import CST2AST;

AForm getAST(str name) {
    name += ".myql";
    pt = parse(#start[Form], |project://sle-rug/examples/| + name);
    return cst2ast(pt);
}