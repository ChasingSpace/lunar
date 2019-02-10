local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"
local Parser = require "lunar.compiler.syntax.parser"

describe("Parser:parse_expression", function()
  describe("LiteralExpression syntax", function()
    it("should return one NilLiteralExpression node", function()
      local tokens = Lexer.new("nil"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.NilLiteralExpression.new(), ast)
    end)

    it("should return one BooleanLiteralExpression node given a value of true", function()
      local tokens = Lexer.new("true"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.BooleanLiteralExpression.new(true), ast)
    end)

    it("should return one BooleanLiteralExpression node given a value of false", function()
      local tokens = Lexer.new("false"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.BooleanLiteralExpression.new(false), ast)
    end)

    it("should return one NumberLiteralExpression node given a value of 100", function()
      local tokens = Lexer.new("100"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.NumberLiteralExpression.new(100), ast)
    end)

    it("should return one StringLiteralExpression node given a string value", function()
      local tokens = Lexer.new("'Hello, world!'"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.StringLiteralExpression.new("'Hello, world!'"), ast)
    end)

    it("should return one VariableArgumentExpression node", function()
      local tokens = Lexer.new("..."):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.VariableArgumentExpression.new(), ast)
    end)

    it("should return one FunctionExpression node whose parameters has two ParameterDeclaration nodes and a BreakStatement block", function()
      local tokens = Lexer.new("function(hello, ...) break end"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local expected_params = { AST.ParameterDeclaration.new("hello"), AST.ParameterDeclaration.new("...") }
      local expected_block = { AST.BreakStatement.new() }

      assert.same(AST.FunctionExpression.new(expected_params, expected_block), ast)
    end)

    it("should return one TableLiteralExpression node with three FieldDeclaration nodes", function()
      local tokens = Lexer.new("{ ['hello'] = true, world = false; nil; }"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local expected_fields = {
        AST.FieldDeclaration.new(AST.StringLiteralExpression.new("'hello'"), AST.BooleanLiteralExpression.new(true)),
        AST.FieldDeclaration.new(TokenInfo.new(TokenType.identifier, "world", 21), AST.BooleanLiteralExpression.new(false)),
        AST.FieldDeclaration.new(nil, AST.NilLiteralExpression.new()),
      }

      assert.same(AST.TableLiteralExpression.new(expected_fields), ast)
    end)
  end)

  describe("BinaryOpExpression syntax", function()
    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is addition_op", function()
      local tokens = Lexer.new("1 + 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.addition_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is subtraction_op", function()
      local tokens = Lexer.new("1 - 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.subtraction_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is multiplication_op", function()
      local tokens = Lexer.new("1 * 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.multiplication_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is division_op", function()
      local tokens = Lexer.new("1 / 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.division_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is modulus_op", function()
      local tokens = Lexer.new("1 % 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.modulus_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is power_op", function()
      local tokens = Lexer.new("1 ^ 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.power_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is concatenation_op", function()
      local tokens = Lexer.new("'Hello' .. 'world'"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.StringLiteralExpression.new("'Hello'")
      local operator = AST.BinaryOpKind.concatenation_op
      local right_operand = AST.StringLiteralExpression.new("'world'")

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is not_equal_op", function()
      local tokens = Lexer.new("'Hello' ~= 'world'"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.StringLiteralExpression.new("'Hello'")
      local operator = AST.BinaryOpKind.not_equal_op
      local right_operand = AST.StringLiteralExpression.new("'world'")

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is equal_op", function()
      local tokens = Lexer.new("'Hello' == 'world'"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.StringLiteralExpression.new("'Hello'")
      local operator = AST.BinaryOpKind.equal_op
      local right_operand = AST.StringLiteralExpression.new("'world'")

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is less_than_op", function()
      local tokens = Lexer.new("1 < 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.less_than_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is less_or_equal_op", function()
      local tokens = Lexer.new("1 <= 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.less_or_equal_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is greater_than_op", function()
      local tokens = Lexer.new("1 > 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.greater_than_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is greater_or_equal_op", function()
      local tokens = Lexer.new("1 >= 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.NumberLiteralExpression.new(1)
      local operator = AST.BinaryOpKind.greater_or_equal_op
      local right_operand = AST.NumberLiteralExpression.new(2)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are BooleanLiteralExpression and operator is and_op", function()
      local tokens = Lexer.new("true and false"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.BooleanLiteralExpression.new(true)
      local operator = AST.BinaryOpKind.and_op
      local right_operand = AST.BooleanLiteralExpression.new(false)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)

    it("should return a BinaryOpExpression node whose operands are BooleanLiteralExpression and operator is or_op", function()
      local tokens = Lexer.new("false or true"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local left_operand = AST.BooleanLiteralExpression.new(false)
      local operator = AST.BinaryOpKind.or_op
      local right_operand = AST.BooleanLiteralExpression.new(true)

      assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
    end)
  end)

  describe("UnaryOpExpression syntax", function()
    it("should return an UnaryOpExpression node whose operand is BooleanLiteralExpression and operator is not_op", function()
      local tokens = Lexer.new("not false"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local operator = AST.UnaryOpKind.not_op
      local operand = AST.BooleanLiteralExpression.new(false)

      assert.same(AST.UnaryOpExpression.new(operator, operand), ast)
    end)

    it("should return an UnaryOpExpression node whose operand is NumberLiteralExpression and operator is negative_op", function()
      local tokens = Lexer.new("-1"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local operator = AST.UnaryOpKind.negative_op
      local operand = AST.NumberLiteralExpression.new(1)

      assert.same(AST.UnaryOpExpression.new(operator, operand), ast)
    end)

    it("should return an UnaryOpExpression node whose operand is TableLiteralExpression and operator is length_op", function()
      local tokens = Lexer.new("#{}"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local operator = AST.UnaryOpKind.length_op
      local operand = AST.TableLiteralExpression.new({})

      assert.same(AST.UnaryOpExpression.new(operator, operand), ast)
    end)
  end)

  describe("ExpressionList syntax", function()
    it("should return an array of two expression nodes", function()
      local tokens = Lexer.new("1, 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression_list()

      assert.same({ AST.NumberLiteralExpression.new(1), AST.NumberLiteralExpression.new(2) }, ast)
    end)
  end)
end)
