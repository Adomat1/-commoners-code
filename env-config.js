const fs = require('fs');
const path = require('path');

/**
 * Parse a .env file and return key-value pairs.
 * Supports comments (#), empty lines, quoted values (single/double),
 * and multiline values within quotes.
 */
function parseEnvFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const env = {};
  const lines = content.split('\n');
  let currentKey = null;
  let currentValue = '';
  let inMultiline = false;
  let quoteChar = null;

  for (const line of lines) {
    if (inMultiline) {
      currentValue += '\n' + line;
      if (line.includes(quoteChar)) {
        const endIdx = line.indexOf(quoteChar);
        currentValue = currentValue.slice(0, currentValue.length - line.length + endIdx);
        env[currentKey] = currentValue;
        inMultiline = false;
        currentKey = null;
        currentValue = '';
        quoteChar = null;
      }
      continue;
    }

    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;

    const eqIdx = trimmed.indexOf('=');
    if (eqIdx === -1) continue;

    const key = trimmed.slice(0, eqIdx).trim();
    let value = trimmed.slice(eqIdx + 1).trim();

    if ((value.startsWith('"') || value.startsWith("'")) && !value.endsWith(value[0])) {
      quoteChar = value[0];
      currentKey = key;
      currentValue = value.slice(1);
      inMultiline = true;
      continue;
    }

    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }

    env[key] = value;
  }

  return env;
}

/**
 * Load environment variables from a .env file into process.env.
 * Does not overwrite existing process.env values by default.
 *
 * @param {object} options
 * @param {string} options.path - Path to .env file (default: .env in cwd)
 * @param {boolean} options.override - Overwrite existing env vars (default: false)
 * @param {string[]} options.required - List of required variable names
 * @returns {object} The parsed key-value pairs
 */
function loadEnv(options = {}) {
  const envPath = options.path || path.resolve(process.cwd(), '.env');
  const override = options.override || false;
  const required = options.required || [];

  if (!fs.existsSync(envPath)) {
    throw new Error(`Environment file not found: ${envPath}`);
  }

  const parsed = parseEnvFile(envPath);

  for (const [key, value] of Object.entries(parsed)) {
    if (override || process.env[key] === undefined) {
      process.env[key] = value;
    }
  }

  const missing = required.filter(key => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }

  return parsed;
}

module.exports = { loadEnv, parseEnvFile };
