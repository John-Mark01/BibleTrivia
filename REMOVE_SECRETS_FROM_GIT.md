# How to Remove Sensitive Files from Git History

This guide provides step-by-step instructions for completely removing sensitive files (like API keys, passwords, or secrets) from your git repository history.

## ⚠️ **CRITICAL: Do This IMMEDIATELY**

Before following these steps:
1. **Revoke/regenerate any exposed credentials** (API keys, tokens, passwords)
2. **Notify your team** if this is a shared repository
3. **Backup your repository** before starting

## 🛠️ **Step-by-Step Removal Process**

### Step 1: Remove File from Git History

Use `git filter-branch` to remove the file from all commits:

```bash
# Remove file using index-filter (faster, works on git index)
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch 'path/to/sensitive/file.ext'" --prune-empty --tag-name-filter cat -- --all

# Alternative: Remove file using tree-filter (slower, works on actual files)
git filter-branch --force --tree-filter "rm -f path/to/sensitive/file.ext" --prune-empty HEAD
```

### Step 2: Clean Up Git References

Remove backup references created by filter-branch:

```bash
# Remove backup references
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
```

### Step 3: Expire Reflog

Force expire all reflog entries:

```bash
# Expire all reflog entries immediately
git reflog expire --expire=now --all
```

### Step 4: Garbage Collection

Force git to remove all unreachable objects:

```bash
# Aggressive garbage collection to remove all traces
git gc --prune=now --aggressive
```

### Step 5: Verify Removal

Check that the sensitive data is completely gone:

```bash
# Search for any remaining traces of the file
git log --all --full-history -- "**/filename.ext"

# Search for specific content (replace with your sensitive data)
git log --all -S "sensitive_content_here" --oneline

# Check current tracked files
git ls-files | grep -i sensitive

# Search all git objects for sensitive content
git rev-list --objects --all | grep -i sensitive
```

### Step 6: Force Push to Remote

⚠️ **Warning**: This will rewrite history on the remote repository.

```bash
# Check your remote repositories
git remote -v

# Force push to overwrite remote history
git push origin main --force-with-lease

# If you have multiple branches, push all:
git push --force-with-lease --all
```

## 🔄 **Alternative Method: Using git-filter-repo**

For newer git versions, `git-filter-repo` is the recommended tool:

### Install git-filter-repo:
```bash
# macOS
brew install git-filter-repo

# Ubuntu/Debian
sudo apt install git-filter-repo

# Python pip
pip install git-filter-repo
```

### Remove file using git-filter-repo:
```bash
# Remove specific file
git filter-repo --path path/to/sensitive/file.ext --invert-paths

# Remove files matching pattern
git filter-repo --path-glob '**/secrets.*' --invert-paths

# Remove content containing specific strings
git filter-repo --replace-text expressions.txt
```

## 🛡️ **Prevention Measures**

### 1. Update .gitignore
Add patterns to prevent future accidents:

```gitignore
# Secrets and Environment Variables
.env
.env.local
.env.production
.env.staging

# Configuration Files
config.plist
Config.plist
secrets.plist
Secrets.plist
app-config.plist
AppConfig.plist

# API Keys and Tokens
**/secrets/
**/config/secrets.*
apikey.txt
token.txt
keys.plist
api-keys.plist
```

### 2. Use Environment Variables
Replace hardcoded secrets with environment variables:

```swift
// Bad ❌
static let apiKey = "hardcoded_api_key_here"

// Good ✅
static var apiKey: String {
    guard let key = ProcessInfo.processInfo.environment["API_KEY"] else {
        fatalError("API_KEY environment variable not set")
    }
    return key
}
```

### 3. Set Up Pre-commit Hooks
Use tools like `git-secrets` or `detect-secrets`:

```bash
# Install git-secrets
brew install git-secrets

# Set up git-secrets for your repo
git secrets --install
git secrets --register-aws
```

## 🚨 **Security Checklist After Removal**

- [ ] **Revoked/regenerated all exposed credentials**
- [ ] **Verified sensitive data is completely removed from git history**
- [ ] **Force pushed clean history to remote repository**
- [ ] **Updated .gitignore to prevent future accidents**
- [ ] **Implemented secure credential management**
- [ ] **Notified team members about the security incident**
- [ ] **Set up monitoring for exposed credentials** (GitHub secret scanning, etc.)

## 📝 **Important Notes**

1. **Rewriting History**: These commands rewrite git history. All collaborators will need to re-clone the repository.

2. **Backup**: Always backup your repository before running these commands.

3. **Timing**: The sooner you do this after the accidental commit, the better.

4. **Monitoring**: Set up alerts for your exposed credentials in case they were already scraped by bots.

5. **Team Communication**: Inform all team members about the process and coordinate the cleanup.

## 🔍 **Verification Commands Summary**

```bash
# Quick verification checklist
git log --all --full-history -- "**/Secrets.swift"                    # Should return nothing
git log --all -S "your_api_key_here" --oneline                       # Should return nothing  
git ls-files | grep -i secret                                         # Should return nothing
git rev-list --objects --all | grep -i secret                        # Should return nothing
git log --all -p --grep="your_exposed_url"                           # Should return nothing
```

## ⚡ **Quick Reference Commands**

```bash
# The complete process in one script:
#!/bin/bash
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch 'path/to/file'" --prune-empty --tag-name-filter cat -- --all
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push origin main --force-with-lease
```

---

**Remember**: The best defense against exposed secrets is prevention. Always use secure credential management practices from the start of your project. 
