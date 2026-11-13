const entries = new Map();

function set(key, value, ttlMs = 300000) {
  entries.set(key, { value, expiresAt: Date.now() + ttlMs });
}

function get(key) {
  const entry = entries.get(key);
  if (!entry) return undefined;
  if (entry.expiresAt <= Date.now()) {
    entries.delete(key);
    return undefined;
  }
  return entry.value;
}

function del(key) {
  entries.delete(key);
}

function clear() {
  entries.clear();
}

module.exports = { set, get, del, clear };
