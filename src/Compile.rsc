module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

HTMLElement form2html(AForm f) {
  HTMLElement body = body([form([])]);
  HTMLElement head = head([]);
  HTMLElement input_elem;
  for (AQuestion question <- f.questions)
  {
    question_elem = div([], name = question.text.name);
    body.elems += [question_elem];
    switch (question.datatype) {
        case booleanType():
            input_elem = input([], \type = "checkbox", name = question.variable);
        case integerType():
            input_elem = input([], \type = "number", name = question.variable);
        case stringType():
            input_elem = input([], \type = "text", name = question.variable);
    }
  }
      
  list[HTMLElement] elements = [head, body];
  return html(elements);
}

str form2js(AForm f) {
  return "";
}
