# CLAUDE.md

Quality software engineering in this repository.

## Core Principles

1. **Be thorough** - Complete the entire task, including tests, documentation updates, and edge cases.

## Decision Framework

### Act Without Asking

- Creating branches and PRs
- Updating documentation affected by your changes

## Workflow

### Starting a Task

1. Understand the full scope before writing code
2. Check for existing patterns in the codebase - follow them
3. Create a feature branch: `feature/short-description` or `fix/short-description`

### During Development

1. Write code that matches existing style (indentation, naming, structure)
2. Add tests for new functionality
3. Update tests for modified functionality
4. Keep commits atomic and well-described

### Completing a Task

1. Run the test suite - all tests must pass
2. Run the linter/formatter if the project has one
3. Create a PR with clear title and description
4. List what changed and why in the PR body

## Code Quality

### Tests

- Every new feature needs tests
- Every bug fix needs a regression test
- Tests should be fast and deterministic
- Mock external services, don't call them

### Style

- Use descriptive names over comments
- Keep functions small and focused
- Handle errors explicitly

### Security

- Never hardcode secrets
- Validate all external input
- Escape output appropriately

## Language-Specific Guidance

This repo may contain multiple languages. For language-specific practices:

- **Python**: Check python-skill.
- **TypeScript/JavaScript**: Check check typescript-skill.


## Project Structure Discovery

Before making changes, understand the project:

1. Check `README.md` for project overview
2. Check dependencies and scripts
3. Look at the directory structure to understand organization
4. Find existing tests to understand testing patterns
5. Check CI configuration (`.github/workflows/`) for build/test commands

## Error Recovery

If something goes wrong:

1. **Test failure**: Read the error, fix the code, run again
2. **Lint failure**: Run the formatter, commit the fix
3. **Build failure**: Check dependencies, check syntax, read the error carefully
4. **Git conflict**: Understand both changes, merge thoughtfully
5. **Stuck**: Explain what you tried and what failed, then ask for guidance

## PR Guidelines

### Title Format

- `feat: Add user authentication`
- `fix: Resolve crash on empty input`
- `refactor: Simplify payment processing`
- `docs: Update API documentation`
- `test: Add integration tests for checkout`

### Description Template

```markdown
## Summary
Brief description of what this PR does.

## Changes
- Bullet points of specific changes

## Test Plan
How to verify this works.
```

## Autonomy Checklist

Before asking a question, check:

- [ ] Did I search the codebase for similar patterns?
- [ ] Did I read the README and related docs?
- [ ] Did I try at least one approach?
- [ ] Is this truly ambiguous, or am I just uncertain?
- [ ] Would a senior engineer ask this, or just decide?

If you checked all boxes and still need guidance, ask concisely with context.
