# Copilot Instructions for FixNapalmLag Plugin

## Repository Overview
This repository contains a SourceMod plugin called "FixNapalmLag" that prevents server lag when napalm damage is applied to players in Source engine games (Counter-Strike). The plugin hooks the game's RadiusDamage function using DHooks to block specific types of burn damage that cause performance issues.

## Technical Environment
- **Language**: SourcePawn (.sp files)
- **Platform**: SourceMod 1.11+ (minimum version specified in sourceknight.yaml)
- **Game Engines**: Source Engine (CS:GO, CS:S)
- **Build System**: SourceKnight (modern SourceMod build tool)
- **Compiler**: SourcePawn Compiler (spcomp) via SourceKnight
- **Dependencies**: 
  - SourceMod Core
  - DHooks extension (for function hooking)
  - SDKHooks, SDKTools (standard SourceMod includes)

## Project Structure
```
/addons/sourcemod/
├── scripting/
│   └── FixNapalmLag.sp          # Main plugin source code
└── gamedata/
    └── fixnapalmlag.games.txt   # Game data with memory offsets

/.github/
├── workflows/
│   └── ci.yml                   # CI/CD pipeline using SourceKnight
└── dependabot.yml               # Dependency management

/sourceknight.yaml               # Build configuration
/.gitignore                      # Git ignore patterns
```

## Build System (SourceKnight)
This project uses SourceKnight as its build system instead of traditional spcomp compilation:

### Configuration File: `sourceknight.yaml`
- Defines project dependencies (SourceMod version)
- Specifies build targets
- Configures output directories
- Handles automatic dependency downloading

### Build Commands
```bash
# Using SourceKnight action (in CI)
uses: maxime1907/action-sourceknight@v1
with:
  cmd: build

# Local development (if SourceKnight is installed)
sourceknight build
```

### CI/CD Pipeline
- Builds on `ubuntu-24.04`
- Creates release packages automatically
- Uploads artifacts for distribution
- Supports both tagged releases and latest builds

## Code Style & Standards

### SourcePawn Best Practices
```sourcepawn
#pragma semicolon 1          // Always required
#pragma newdecls required    // Use new declaration syntax

// Variable naming conventions
Handle g_hVariableName = INVALID_HANDLE;  // Global handles with g_h prefix
int g_iGlobalInt;                          // Global integers with g_i prefix
char g_sGlobalString[64];                  // Global strings with g_s prefix

// Function naming
public void OnPluginStart()               // Plugin lifecycle functions
public MRESReturn Hook_FunctionName()     // Hook functions with Hook_ prefix

// Memory management
CloseHandle(hHandle);                      // Always close handles
delete someObject;                         // Use delete for modern objects
```

### Code Quality Requirements
- Use descriptive variable and function names
- Implement proper error handling for all API calls
- Check return values from game functions
- Use DHooks for memory-safe function hooking
- Validate parameters before use (e.g., `DHookIsNullParam()`)

## Plugin-Specific Implementation Details

### Core Functionality
The plugin hooks the `RadiusDamage` function to:
1. Filter burn damage (`DMG_BURN` flag)
2. Block napalm damage from players (entities 1-MaxClients)
3. Block napalm damage from grenades (`hegrenade_projectile`)

### Critical Code Patterns
```sourcepawn
// DHooks setup pattern
Handle g_hRadiusDamage = DHookCreate(offset, HookType_GameRules, ReturnType_Void, ThisPointer_Ignore, Hook_RadiusDamage);
DHookAddParam(g_hRadiusDamage, HookParamType_ObjectPtr);  // CTakeDamageInfo &info
DHookAddParam(g_hRadiusDamage, HookParamType_VectorPtr);  // Vector &vecSrc
// ... more parameters

// Hook callback pattern
public MRESReturn Hook_RadiusDamage(Handle hParams)
{
    // Always check for null parameters
    if(DHookIsNullParam(hParams, 5))
        return MRES_Ignored;
    
    // Extract data from hook parameters
    int iDmgBits = DHookGetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Int);
    
    // Return appropriate action
    return MRES_Supercede; // Block the function
    return MRES_Ignored;   // Allow the function
}
```

### Game Data Management
- Offsets are defined in `fixnapalmlag.games.txt`
- Support multiple game versions (cstrike, csgo)
- Platform-specific offsets (Windows, Linux, Mac)
- Always validate gamedata loading success

## Development Workflow

### Making Changes
1. **Edit Source Code**: Modify `addons/sourcemod/scripting/FixNapalmLag.sp`
2. **Update Game Data**: If needed, modify `addons/sourcemod/gamedata/fixnapalmlag.games.txt`
3. **Test Locally**: Use SourceKnight build or test on development server
4. **CI Validation**: Push changes trigger automated builds

### Testing Guidelines
- Test on actual game servers when possible
- Verify napalm damage is properly blocked
- Ensure no false positives (normal damage still works)
- Monitor server performance under load
- Test with different game modes and maps

### Version Management
- Version is defined in plugin info block
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version when making functional changes
- CI automatically creates releases for tags

## Performance Considerations
- This plugin runs on frequently called damage functions
- Minimize operations in hook callbacks
- Use efficient entity validation
- Cache expensive lookups when possible
- Be mindful of string operations in hot paths

## Common Issues & Troubleshooting

### Build Issues
- Ensure SourceKnight dependencies are available
- Verify gamedata file is found and loaded
- Check SourceMod version compatibility

### Runtime Issues
- Validate DHooks extension is loaded
- Ensure game offsets are correct for current game version
- Monitor for crashes due to invalid memory access
- Check entity validity before accessing properties

## Contributing Guidelines
- Follow existing code style and conventions
- Test changes thoroughly on live servers
- Update comments for any complex logic changes
- Ensure compatibility with minimum SourceMod version
- Keep changes minimal and focused on the plugin's purpose

## Dependencies & Compatibility
- **SourceMod**: 1.11.0+ (as specified in sourceknight.yaml)
- **DHooks**: Required for function hooking
- **Games**: Counter-Strike: Source, Counter-Strike: Global Offensive
- **Platforms**: Windows, Linux, macOS (with appropriate gamedata offsets)

## Key Files to Understand
- `FixNapalmLag.sp`: Core plugin logic and DHooks implementation
- `fixnapalmlag.games.txt`: Game-specific memory offsets
- `sourceknight.yaml`: Build configuration and dependencies
- `.github/workflows/ci.yml`: Automated build and release process