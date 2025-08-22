---============================================================================
--- FFXI GearSwap Messages - Job-Specific Message Functions (DEPRECATED)
---============================================================================
--- This file has been modularized into separate job files.
--- This compatibility wrapper redirects to the new modular system.
---
--- @file messages/MESSAGE_JOBS.lua
--- @author Tetsouo
--- @version 2.0 (Modularized)
--- @date Created: 2025-08-20 | Modularized: 2025-08-22
--- @deprecated Use messages/MESSAGE_JOBS_LOADER.lua and messages/jobs/MESSAGE_*.lua
---============================================================================

-- Redirect to the new modular system
local success, MessageJobsLoader = pcall(require, 'messages/MESSAGE_JOBS_LOADER')
if not success then
    error("Failed to load modular message system: " .. tostring(MessageJobsLoader))
end

-- For backward compatibility, return the loader
-- All functions are exported by the loader system
return MessageJobsLoader