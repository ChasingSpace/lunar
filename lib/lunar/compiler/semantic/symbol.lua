local Symbol = {}
Symbol.__index = {}

function Symbol.constructor(self, name)
  self.name = name
  self.assignment_references = {} -- Identifier[]
  self.references = {} -- Identifier[]
  self.declarations = {} -- Node[]
  self.declaration_references = {} -- Identifier[]
  self.builtin = false

  self.members = nil -- SymbolTable or nil; should include class and interface instance members
  self.exports = nil -- SymbolTable or nil; should include class statics, as well as module exports
end

function Symbol.__index:is_builtin()
  return self.builtin
end

function Symbol.__index:is_assigned()
  return #self.assignment_references > 0
end

function Symbol.__index:is_declared()
  return #self.declarations > 0
end

function Symbol.__index:is_redeclared()
  return #self.declarations > 1
end

function Symbol.__index:get_canonical_declaration()
  return self.declarations[1]
end

function Symbol.__index:is_referenced()
  return #self.references > 0
end

function Symbol.__index:bind_as_builtin()
  self.builtin = true
end

function Symbol.__index:bind_declaration_reference(ident_or_varargs, declaration)
  local refs = self.declaration_references
  refs[#refs + 1] = ident_or_varargs
  ident_or_varargs.symbol = self

  local decls = self.declarations
  decls[#decls + 1] = declaration
end

-- Anonymous declarations (e.g. contextual "self" in classes)
function Symbol.__index:bind_declaration(declaration)
  local decls = self.declarations
  decls[#decls + 1] = declaration
end

function Symbol.__index:bind_reference(ident_or_varargs)
  local refs = self.references
  refs[#refs + 1] = ident_or_varargs
  ident_or_varargs.symbol = self
end

function Symbol.__index:bind_assignment_reference(ident_or_varargs)
  local refs = self.assignment_references
  refs[#refs + 1] = ident_or_varargs
  ident_or_varargs.symbol = self
end

-- Re-binds all references, declarations, exports, and members to a new symbol
function Symbol.__index:merge_into(new_symbol)
  for _, k in pairs({"references", "declarations", "declaration_references", "assignment_references"}) do
    local nodes = self[k]
    local other_nodes = new_symbol[k]
    for i = 1, #nodes do
      local node = nodes[i]
      if node.symbol == self then
        node.symbol = new_symbol
      end
      other_nodes[#other_nodes + 1] = node
    end
  end

  for _, k in pairs({"members", "exports"}) do
    local symtab = self[k]
    if symtab then
      local other_symtab = new_symbol[k]
      if other_symtab then
        for name, symbol in pairs(symtab.values) do
          local other_symbol = other_symtab:get_value(name)
          if other_symbol then
            symbol:merge_into(other_symbol)
          else
            other_symtab:add_value(symbol)
          end
        end

        for name, symbol in pairs(symtab.types) do
          local other_symbol = other_symtab:get_type(name)
          if other_symbol then
            symbol:merge_into(other_symbol)
          else
            other_symtab:add_type(symbol)
          end
        end
      else
        new_symbol[k] = symtab
      end
    end
  end
end

Symbol.__tostring = function(self)
  return "Symbol ('" .. tostring(self.name) .. "')"
end

function Symbol.new(...)
  local self = setmetatable({}, Symbol)
  Symbol.constructor(self, ...)
  return self
end

return Symbol