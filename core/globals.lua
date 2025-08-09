---============================================================================
--- FFXI GearSwap Core Module - Global Functions and Utilities
---============================================================================
--- This module loads and exposes global functions that need to be available
--- across all job files without explicit imports.
---============================================================================

-- Load message utilities and expose createFormattedMessage globally
local MessageUtils = require('utils/messages')

-- Make createFormattedMessage globally available for all jobs
_G.createFormattedMessage = MessageUtils.create_formatted_message

-- Export MessageUtils for jobs that want to use the full API
return {
    MessageUtils = MessageUtils
}