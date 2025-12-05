// Custom Cypress commands for reusable test logic

/**
 * Check if skip-to-main-content link exists and works
 */
Cypress.Commands.add('checkSkipLink', () => {
  cy.get('a.skip-to-main').should('exist').and('have.attr', 'href', '#main-content');
});

/**
 * Check common page elements (header, nav, footer)
 */
Cypress.Commands.add('checkCommonElements', () => {
  cy.get('header').should('be.visible');
  cy.get('nav').should('be.visible');
  cy.get('footer').should('be.visible');
});

/**
 * Check meta description exists
 */
Cypress.Commands.add('checkMetaDescription', () => {
  cy.get('head meta[name="description"]').should('exist').and('have.attr', 'content');
});

/**
 * Check navigation links
 */
Cypress.Commands.add('checkNavigation', () => {
  cy.get('nav a').should('have.length.at.least', 5);
  cy.get('nav a').each(($el) => {
    cy.wrap($el).should('have.attr', 'href');
  });
});
