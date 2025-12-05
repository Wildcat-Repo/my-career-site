# E2E Test Plan - My Career Site

## Overview
This document outlines the end-to-end testing strategy for the personal portfolio website using Cypress.

## Test Objectives
- Verify all pages load correctly
- Validate navigation between pages
- Ensure accessibility features work properly
- Verify content security policy compliance
- Test 404 error handling
- Validate responsive design elements

## Test Scope

### In Scope
- Page loading and rendering
- Navigation functionality
- Accessibility features (skip links, ARIA attributes)
- Meta tag presence
- 404 error page
- Social media links
- Content presence validation

### Out of Scope
- External link validation (LinkedIn, GitHub, Twitter)
- Email functionality testing
- Performance/load testing
- Browser compatibility (handled separately)

## Test Categories

### 1. Navigation Tests
**Purpose:** Ensure users can navigate between all pages

**Test Cases:**
- TC-NAV-001: Verify home page loads
- TC-NAV-002: Navigate from home to each section (About, Portfolio, Research, Contact)
- TC-NAV-003: Verify active page indicator (aria-current)
- TC-NAV-004: Test navigation from each page back to home
- TC-NAV-005: Verify all internal links are functional

### 2. Page Content Tests
**Purpose:** Validate that required content is present on each page

**Test Cases:**
- TC-CONTENT-001: Home page displays welcome message
- TC-CONTENT-002: About page displays professional journey
- TC-CONTENT-003: Portfolio page displays project cards
- TC-CONTENT-004: Research page loads content
- TC-CONTENT-005: Contact page displays email and social links
- TC-CONTENT-006: All pages have proper meta descriptions
- TC-CONTENT-007: All pages have correct titles

### 3. Accessibility Tests
**Purpose:** Ensure the site is accessible to all users

**Test Cases:**
- TC-A11Y-001: Skip to main content link is present on all pages
- TC-A11Y-002: Skip link becomes visible on focus
- TC-A11Y-003: Main content has proper id attribute
- TC-A11Y-004: Navigation uses semantic HTML
- TC-A11Y-005: Images have alt text (if any added in future)
- TC-A11Y-006: Proper heading hierarchy

### 4. Error Handling Tests
**Purpose:** Verify proper error page handling

**Test Cases:**
- TC-ERROR-001: 404 page displays for non-existent routes
- TC-ERROR-002: 404 page shows custom error message
- TC-ERROR-003: 404 page includes navigation to return home
- TC-ERROR-004: 404 page maintains site styling

### 5. UI/Visual Tests
**Purpose:** Verify visual elements render correctly

**Test Cases:**
- TC-UI-001: Header is present and styled on all pages
- TC-UI-002: Footer is present on all pages
- TC-UI-003: Portfolio grid displays properly
- TC-UI-004: Social media icons display on contact page

## Test Environment

### Local Testing
- **Base URL:** http://localhost:3000
- **Command:** `npm run test:e2e`

### CI/CD Pipeline
- **Platform:** Gitea Actions
- **Trigger:** On push to main, pull requests
- **Environment:** Node.js 18+
- **Browser:** Electron (headless)

## Test Data
No test data required - all tests use existing static content.

## Success Criteria
- All test cases pass
- No console errors during test execution
- Page load times < 3 seconds
- Test execution time < 2 minutes

## Maintenance
- Update tests when new pages are added
- Review tests quarterly
- Update when navigation structure changes
- Keep Cypress dependencies up to date
