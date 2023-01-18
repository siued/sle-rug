module Compile

import run;
import AST;
import Resolve;
import Transform;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;
import String;

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
  str html = writeHTMLString(form2html(flattened_f));
  html = replaceAll(html, "&gt;", "\>");
  html = replaceAll(html, "&lt;", "\<");
  html = replaceAll(html, "&amp;", "&");
  writeFile(f.src[extension="html"].top, html);
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
    str condition = ExprToString(ifstatement.expr);
    str htmlCode = "\<div class=\"form-group\" v-if=\"<condition>\"\>";
    htmlCode += " \<label for=\"<question.variable.name>\"\><question.text.name>\</label\>";
    switch (question) {
      case question(_, _, _):
      {
        str \type = "";
        str model = "";
        switch (question.datatype) {
          case booleanType():
          {
            \type = "checkbox";
            model = "v-model = \"<question.variable.name>\"";
          }
          case stringType():
          {
            \type = "text";
            model = "v-model = \"<question.variable.name>\"";
          }
          case integerType():
          {
            \type = "number";
            model = "v-model.number = \"<question.variable.name>\"";
          }
      }
      htmlCode += " \<input type=\"<\type>\" <model>\>";
      }
      case question(_, _, _, _): 
      {
      htmlCode += " \<input type=\"number\" :value = \"<question.variable.name>\" readonly\>";
      }
    }
    htmlCode += "\</div\>";
    htmlCode += "\n\n\n";
    divs += [text(htmlCode)];
  }

  HTMLElement submit = input(class = "form-group", \type = "submit", \value = "Submit");
  divs += [submit];
  HTMLElement form = form(divs);
  HTMLElement d1 = div([form], id = "app");
  HTMLElement script = script([text(form2js(f))]);
  list[HTMLElement] elements = [d1, script];
  return body(elements);
}

HTMLElement makeHead(AForm f) {
  HTMLElement title = title([text(f.name.name)]);
  HTMLElement link = link(\rel = "stylesheet", \type = "text/css", href = "styles.css");
  HTMLElement script = script([], src = "https://cdn.jsdelivr.net/npm/vue/dist/vue.js");
  list[HTMLElement] elements = [title, script];
  return head(elements);
}

str ExprToString(AExpr expr) {
  switch (expr) {
    case datavar(boolean(x)):
      return x;
    case datavar(int x):
      return "<x>";
    case datavar(id(x)):
      return x;
    case not(x):
      return "!" + ExprToString(x);
    case mul(x, y):
      return ExprToString(x) + " * " + ExprToString(y);
    case div(x, y):
      return ExprToString(x) + " / " + ExprToString(y);
    case add(x, y):
      return ExprToString(x) + " + " + ExprToString(y);
    case sub(x, y):
      return ExprToString(x) + " - " + ExprToString(y);
    case lessthan(x, y):
      return ExprToString(x) + " \< " + ExprToString(y);
    case greaterthan(x, y):
      return ExprToString(x) + " \> " + ExprToString(y);
    case lessthanequal(x, y):
      return ExprToString(x) + " \<= " + ExprToString(y);
    case greaterthanequal(x, y):
      return ExprToString(x) + " \>= " + ExprToString(y);
    case equal(x, y):
      return ExprToString(x) + " == " + ExprToString(y);
    case notequal(x, y):
      return ExprToString(x) + " != " + ExprToString(y);
    case and(x, y):
      return ExprToString(x) + " && " + ExprToString(y);
    case or(x, y):
      return ExprToString(x) + " || " + ExprToString(y);
  }
}

str form2js(AForm f) {
  return "";
}
