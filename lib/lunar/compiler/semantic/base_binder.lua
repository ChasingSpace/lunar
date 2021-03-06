local Scope = require("lunar.compiler.semantic.scope")
local LinkingEnvironment = require("lunar.compiler.semantic.linking_environment")
local BaseBinder = {}
BaseBinder.__index = {}
function BaseBinder.new(environment, file_path_dot)
  return BaseBinder.constructor(setmetatable({}, BaseBinder), environment, file_path_dot)
end
function BaseBinder.constructor(self, environment, file_path_dot)
  self.scope = nil
  self.root_scope = nil
  self.level = 0
  self.environment = environment or LinkingEnvironment.new()
  self.file_path = file_path_dot or "src"
  return self
end
function BaseBinder.__index:push_scope(incrementLevel)
  if incrementLevel then
    self.level = self.level + 1
  end
  self.scope = Scope.new(self.level, self.scope, self.environment, self.file_path)
  return self.scope
end
function BaseBinder.__index:pop_level_scopes()
  local removed_scopes = {}
  repeat
    table.insert(removed_scopes, self.scope)
    self.scope = self.scope.parent
  until (not self.scope) or self.scope.level < self.level
  self.level = self.level - 1
  return removed_scopes
end
return BaseBinder
