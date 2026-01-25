local addon, ns = ...

-- create library
local LibStub = _G.LibStub

-- Get the addon version (MAJOR, MINOR, PATCH)
local version = C_AddOns.GetAddOnMetadata("LibRu", "Version")
local parts = {strsplit(".", version)}
local MAJOR = tonumber(parts[1]) or 2
local MINOR = tonumber(parts[2]) or 0
local PATCH = tonumber(parts[3]) or 0

-- Create a single version number for LibStub (MAJOR * 10000 + MINOR * 100 + PATCH)
-- eg. for version 2.3.4, this will be 20000 + 300 + 4 = 20304
-- LibStub only supports major.minor, not semantic versioning with patch
local LIBSTUB_VERSION = MAJOR * 10000 + MINOR * 100 + PATCH


---@class LibRu
ns.LibRu = LibStub:NewLibrary("LibRu", LIBSTUB_VERSION)