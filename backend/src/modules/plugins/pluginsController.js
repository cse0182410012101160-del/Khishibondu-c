const db = require('../../database/store');

// List registered plugins and active feature flags
function getPlugins(req, res) {
  const { role } = req.query;

  let plugins = [...db.plugins];
  if (role) {
    plugins = plugins.filter(p => p.enabledForRoles.includes(role));
  }

  return res.json({
    success: true,
    count: plugins.length,
    plugins
  });
}

// Toggle plugin status (active, disabled, beta)
function togglePlugin(req, res) {
  const { id } = req.params;
  const { status, enabledForRoles, config } = req.body;

  const plugin = db.plugins.find(p => p.id === id);
  if (!plugin) {
    return res.status(404).json({ success: false, message: `Plugin '${id}' not found.` });
  }

  if (status) plugin.status = status;
  if (enabledForRoles) plugin.enabledForRoles = enabledForRoles;
  if (config) plugin.configSchema = { ...plugin.configSchema, ...config };

  return res.json({
    success: true,
    message: `Plugin '${plugin.name}' status updated to '${plugin.status}'.`,
    plugin
  });
}

// Register a new plugin dynamically (Extensibility Hook)
function registerPlugin(req, res) {
  const { id, name, nameBn, description, version, author, icon, status, enabledForRoles, configSchema } = req.body;

  if (!id || !name) {
    return res.status(400).json({ success: false, message: 'Plugin id and name are required.' });
  }

  const existing = db.plugins.find(p => p.id === id);
  if (existing) {
    return res.status(409).json({ success: false, message: `Plugin with id '${id}' already registered.` });
  }

  const newPlugin = {
    id,
    name,
    nameBn: nameBn || name,
    description: description || '',
    version: version || '1.0.0',
    author: author || 'Third-Party Contributor',
    icon: icon || 'extension',
    status: status || 'active',
    enabledForRoles: enabledForRoles || ['farmer', 'buyer', 'admin'],
    configSchema: configSchema || {},
    registeredAt: new Date().toISOString()
  };

  db.plugins.push(newPlugin);

  return res.status(201).json({
    success: true,
    message: `Plugin '${name}' registered successfully into Agro-Bridge runtime.`,
    plugin: newPlugin
  });
}

module.exports = {
  getPlugins,
  togglePlugin,
  registerPlugin
};

