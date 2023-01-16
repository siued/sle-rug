module Compile

import AST;
import Resolve;
import Transform;
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
  AForm flattened_f = flatten(f);
  writeFile(f.src[extension="js"].top, form2js(flattened_f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(flattened_f)));
}

HTMLElement form2html(AForm f) {
  HTMLElement head = makeHead(f);
  HTMLElement body = makeBody(f);
      
  list[HTMLElement] elements = [head, body];
  return html(elements);
}

HTMLElement makeBody(AForm f) {
  list[HTMLElement] divs = [];
  HTMLElement h1 = h1([text(f.name.name)]);
  divs += [h1];
  for(AQuestion ifstatement <- f.questions) {
    AQuestion question = ifstatement.questions[0];
    HTMLElement label = label([text(question.text.name)], \for = question.variable.name);
    HTMLElement xd = input();
    switch (question.datatype) {
      case booleanType():
        xd = input(\type = "checkbox");
      case stringType():
        xd = input(\type = "text");
      case integerType():
        xd = input(\type = "number");
    }
    list[HTMLElement] e = [label, xd];
    HTMLElement div = div(e, class = "form-group");
    divs += [div];
  }

  HTMLElement submit = input(class = "form-group", \type = "submit", \value = "Submit");
  divs += [submit];
  HTMLElement form = form(divs);
  HTMLElement d1 = div([form], name = "app");
  HTMLElement script = script([text(form2js(f))]);
  list[HTMLElement] elements = [d1, script];
  return body(elements);
}

HTMLElement makeHead(AForm f) {
  HTMLElement title = title([text(f.name.name)]);
  // HTMLElement link = link([], \rel = "stylesheet", \type = "text/css", href = "styles.css");
  HTMLElement script = script([], src = "https://cdn.jsdelivr.net/npm/vue/dist/vue.js");
  list[HTMLElement] elements = [title, script];
  return head(elements);
}

str form2js(AForm f) {
  return "";
}
