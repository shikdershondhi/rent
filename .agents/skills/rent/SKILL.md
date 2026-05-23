```markdown
# rent Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the `rent` TypeScript codebase. It covers file organization, import/export styles, commit message conventions, and testing patterns. By following these guidelines, contributors can ensure consistency and maintainability across the project.

## Coding Conventions

### File Naming
- Use **snake_case** for all file names.
  - Example: `user_service.ts`, `rental_manager.test.ts`

### Import Style
- Use **relative imports** for referencing modules within the project.
  - Example:
    ```typescript
    import { calculate_rent } from './rent_utils';
    ```

### Export Style
- Use **named exports** for all modules.
  - Example:
    ```typescript
    // rent_utils.ts
    export function calculate_rent(params: RentParams): number { ... }
    ```

### Commit Messages
- Follow **Conventional Commits** with the `feat` prefix for new features.
  - Example:
    ```
    feat: add rental calculation logic for monthly leases
    ```

## Workflows

### Feature Development
**Trigger:** When implementing a new feature  
**Command:** `/feature-development`

1. Create a new branch for your feature.
2. Use snake_case for any new files.
3. Use relative imports and named exports in your code.
4. Write or update tests in corresponding `*.test.*` files.
5. Commit changes using the `feat` prefix and a descriptive message.
6. Open a pull request for review.

### Testing
**Trigger:** When verifying code functionality  
**Command:** `/run-tests`

1. Identify or create test files matching the `*.test.*` pattern.
2. Run the test suite using the project's test runner (framework not specified).
3. Review test results and fix any failing tests.
4. Ensure all new features are covered by tests.

## Testing Patterns

- Test files follow the pattern: `*.test.*` (e.g., `rental_manager.test.ts`).
- The specific testing framework is not detected; check project documentation or package.json for details.
- Place tests alongside or near the modules they test.
- Example test file structure:
  ```typescript
  // rental_manager.test.ts
  import { calculate_rent } from './rent_utils';

  describe('calculate_rent', () => {
    it('should return correct rent for standard lease', () => {
      expect(calculate_rent({ ... })).toBe(1200);
    });
  });
  ```

## Commands
| Command             | Purpose                                         |
|---------------------|-------------------------------------------------|
| /feature-development| Guide for adding a new feature                  |
| /run-tests          | Steps to execute and verify the test suite      |
```
