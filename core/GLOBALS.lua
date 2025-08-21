---============================================================================
--- FFXI GearSwap Core Module - Global Functions and Utilities
---============================================================================
--- This module loads and exposes global functions that need to be available
--- across all job files without explicit imports. Provides centralized access
--- to commonly used utilities through global namespace injection.
---
--- @file core/globals.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-19
--- @requires utils/messages.lua
---
--- Features:
---   - Global function injection for cross-job availability
---   - Centralized message utility access
---   - Safe loading with error handling
---   - Module export for explicit imports
---
--- @usage
---   -- Automatically loaded by job files
---   -- Provides: _G.createFormattedMessage()
---============================================================================

--- Load message utilities and expose createFormattedMessage globally.
--- Provides safe loading with error handling and global namespace injection.
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

--- Make createFormattedMessage globally available for all jobs.
--- @function _G.createFormattedMessage
--- @param ... any Arguments passed to MessageUtils.create_formatted_message
--- @return string Formatted message string
_G.createFormattedMessage = MessageUtils.create_formatted_message

--- Export MessageUtils for jobs that want to use the full API.
--- @return table Module exports with MessageUtils reference
return {
    MessageUtils = MessageUtils
}
