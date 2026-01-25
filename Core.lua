local addon, ns = ...

--- Define Library Version
local MAJOR = 2
local MINOR = 0
local PATCH = 0

-- Create a single version number for LibStub (MAJOR * 10000 + MINOR * 100 + PATCH)
-- eg. for version 2.3.4, this will be 20000 + 300 + 4 = 20304
-- LibStub only supports major.minor, not semantic versioning with patch
local LIBSTUB_VERSION = MAJOR * 10000 + MINOR * 100 + PATCH


---@class LibRu
ns.LibRu = LibStub:NewLibrary("LibRu", LIBSTUB_VERSION)