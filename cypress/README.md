# Cypress E2E Testing

## Overview
This directory contains end-to-end tests for the My Career Site using Cypress.

## Directory Structure
```
cypress/
├── e2e/                    # Test specification files
│   ├── navigation.cy.js    # Navigation and routing tests
│   ├── accessibility.cy.js # Accessibility compliance tests
│   ├── content.cy.js       # Content validation tests
│   └── error-handling.cy.js# 404 error page tests
├── support/                # Support files and custom commands
│   ├── e2e.js             # Test configuration and setup
│   └── commands.js        # Custom Cypress commands
├── fixtures/              # Test data (currently empty)
├── screenshots/           # Test failure screenshots (gitignored)
└── videos/               # Test run videos (gitignored)
```

## Running Tests

### Prerequisites
1. Install dependencies:
   ```bash
   npm install
   ```

2. Verify Cypress installation:
   ```bash
   npm run cy:verify
   ```

### Local Development

**Start the server first** (in a separate terminal):
```bash
npm start
```

Then run tests:

#### Headless Mode (CI-style)
```bash
npm test
# or
npm run test:e2e
```

#### Headed Mode (See browser)
```bash
npm run test:e2e:headed
```

#### Interactive Mode (Cypress UI)
```bash
npm run test:open
```

## Test Suites

### Navigation Tests (9 tests)
- Page loading
- Navigation between sections
- Active page indicators
- Sequential navigation

### Accessibility Tests (37 tests)
- Skip-to-main-content links
- ARIA attributes
- Semantic HTML structure
- Keyboard navigation
- Proper heading hierarchy

### Content Tests (34 tests)
- Page titles and meta descriptions
- Required content presence
- Project cards display
- Social media links
- Common elements across pages

### Error Handling Tests (7 tests)
- 404 page display
- Custom error messages
- Navigation from error page
- Style consistency

## CI/CD Integration

Tests run automatically in Gitea Actions on:
- Push to `main` branch
- Pull requests to `main`

The workflow:
1. Sets up Node.js (versions 18.x and 20.x)
2. Installs dependencies
3. Starts the server
4. Runs all Cypress tests
5. Uploads screenshots on failure
6. Uploads videos for all runs

## Custom Commands

Located in `cypress/support/commands.js`:

- `cy.checkSkipLink()` - Verify skip-to-main-content link
- `cy.checkCommonElements()` - Verify header, nav, footer
- `cy.checkMetaDescription()` - Verify meta description exists
- `cy.checkNavigation()` - Verify navigation links

## Test Coverage

**Total: 87 test cases**
- Navigation: 9 tests
- Accessibility: 37 tests  
- Content: 34 tests
- Error Handling: 7 tests

## Writing New Tests

1. Create a new spec file in `cypress/e2e/`
2. Follow the naming convention: `feature-name.cy.js`
3. Use descriptive test names with TC-IDs
4. Leverage custom commands for common operations
5. Group related tests with `describe()` blocks

Example:
```javascript
describe('My Feature Tests', () => {
  beforeEach(() => {
    cy.visit('/my-page');
  });

  it('TC-FEATURE-001: Should do something', () => {
    cy.get('selector').should('exist');
  });
});
```

## Troubleshooting

**Server not starting:**
- Ensure port 8000 is available
- Check `server.js` for errors

**Tests timing out:**
- Increase timeout in `cypress.config.js`
- Check network connectivity

**Screenshots not saved:**
- Verify `cypress/screenshots/` directory exists
- Check disk space

**Flaky tests:**
- Add appropriate waits: `cy.wait()`
- Use `cy.intercept()` for API calls
- Check for race conditions

## Resources
- [Cypress Documentation](https://docs.cypress.io/)
- [Test Plan](../TEST_PLAN.md)
- [Best Practices](https://docs.cypress.io/guides/references/best-practices)
