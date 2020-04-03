---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2018/6/10 21:12
---

---@class Game.Core.Ioc.IocBootstrap
local IocBootstrap = class("IocBootstrap")
local IocBinder = require("Betel.Ioc.IocBinder")
local MediatorContext = require("Game.Core.Ioc.MediatorContext")
local ModelContext = require("Game.Core.Ioc.ModelContext")
local ServiceContext = require("Game.Core.Ioc.ServiceContext")

function IocBootstrap:Ctor()
    self.binder = IocBinder.New()
end

function IocBootstrap:Launch()
    self.mediatorContext = MediatorContext.New(self.binder)
    self.mediatorContext:Launch()

    self.modelContext = ModelContext.New(self.binder)
    self.modelContext:Launch()

    self.serviceContext = ServiceContext.New(self.binder)
    self.serviceContext:Launch()

    self.binder:InjectSingleEachOther()
end

return IocBootstrap