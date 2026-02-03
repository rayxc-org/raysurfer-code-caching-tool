# Raysurfer Code Caching Plugin

Claude Code plugin that provides automatic code caching integration.

## Installation

Add to your Claude Code plugins:

```bash
cp -r raysurfer-code-caching-tool ~/.claude/plugins/raysurfer
```

Or add to `.mcp.json`:

```json
{
  "plugins": ["raysurfer-code-caching-tool"]
}
```

## Setup

```bash
export RAYSURFER_API_KEY=your_api_key_here
```

Get your key from the [dashboard](https://raysurfer.com/dashboard/api-keys).

## How It Works

The plugin automatically:

1. **Checks cache** before code generation
2. **Injects cached code** into the agent context when matches are found
3. **Uploads successful code** after task completion

No manual intervention required once configured.

## Features

- Automatic cache lookup for coding tasks
- Background code upload after successful execution
- Seamless integration with existing Claude Code workflows

## License

MIT
