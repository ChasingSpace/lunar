local Scope = require "lunar.compiler.semantic.scope"
local Symbol = require "lunar.compiler.semantic.symbol"

local BaseBinder = {}
BaseBinder.__index = {}

--[[
    A binder should take in an AST and mutate its nodes by binding symbols
]]

function BaseBinder.constructor(self, environment)
  self.scope = nil
  self.level = 0
  self.global_scope = self:push_scope(true)

  -- Copy environment into global scope
  if environment then
    for name, symbol in pairs(environment.values) do
      self.global_scope.values[name] = symbol
    end
    for name, symbol in pairs(environment.types) do
      self.global_scope.types[name] = symbol
    end
  end
end

function BaseBinder.new(...)
  local self = setmetatable({}, BaseBinder)
  BaseBinder.constructor(self, ...)
  return self
end

--[[ Adds to the linked list of scopes ]]
function BaseBinder.__index:push_scope(incrementLevel)
  if incrementLevel then
    self.level = self.level + 1
  end
  self.scope = Scope.new(self.level, self.scope)

  return self.scope
end

--[[ Removes all scopes at the current level ]]
function BaseBinder.__index:pop_level_scopes()
  local removed_scopes = {}
  repeat
    table.insert(removed_scopes, self.scope)
    self.scope = self.scope.parent
  until not self.scope or self.scope.level < self.level
  self.level = self.level - 1

  return removed_scopes
end

--[[ Creates a new symbol in the current scope if it does not exist, and binds it to a given node ]]
function BaseBinder.__index:bind_local_value_symbol(node, name)
  local existing = self.scope:get_value(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.scope:add_value(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the global scope if it does not exist, and binds it to a given node ]]
function BaseBinder.__index:bind_global_value_symbol(node, name)
  local existing = self.global_scope:get_value(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.global_scope:add_value(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the current scope if it does not exist, and binds it to a given node.
Returns the registered symbol ]]
function BaseBinder.__index:bind_local_type_symbol(node, name)
  local existing = self.scope:get_type(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.scope:add_type(symbol)
  
    return symbol
  end
end

--[[ Creates a new symbol in the global scope if it does not exist, and binds it to a given node.
Returns the registered symbol ]]
function BaseBinder.__index:bind_global_type_symbol(node, name)
  local existing = self.global_scope:get_type(name)
  if existing then
    node.symbol = existing
    return existing
  else
    local symbol = Symbol.new(name)
    node.symbol = symbol
    self.global_scope:add_type(symbol)
  
    return symbol
  end
end

return BaseBinder
