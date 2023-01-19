module run

import ParseTree;
import AST;
import Syntax;
import CST2AST;

AForm getAST() {
    pt = parse(#start[Form], |project://sle-rug/examples/tax.myql|);
    return cst2ast(pt);
}