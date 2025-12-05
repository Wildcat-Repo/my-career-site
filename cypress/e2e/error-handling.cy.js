/// <reference types="cypress" />

describe('Error Handling Tests', () => {
  it('TC-ERROR-001: Should display 404 page for non-existent route', () => {
    cy.request({ url: '/non-existent-page', failOnStatusCode: false }).then((response) => {
      expect(response.status).to.eq(404);
    });
  });

  it('TC-ERROR-002: Should show custom 404 error message', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false });
    cy.get('.error-code').should('contain', '404');
    cy.get('.error-message').should('contain', 'Page Not Found');
  });

  it('TC-ERROR-003: Should have navigation to return home from 404', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false });
    cy.get('a.back-home').should('exist').and('have.attr', 'href', '/index.html');
    cy.get('a.back-home').click();
    cy.url().should('include', 'index.html');
  });

  it('TC-ERROR-004: 404 page should maintain site styling', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false });
    cy.get('header').should('be.visible');
    cy.get('nav').should('be.visible');
    cy.get('footer').should('be.visible');
  });

  it('Should have proper 404 page structure', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false });
    cy.get('.error-container').should('exist');
    cy.get('.error-code').should('be.visible');
    cy.get('.error-message').should('be.visible');
    cy.get('.error-description').should('be.visible');
  });

  it('404 page navigation should work correctly', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false });
    cy.get('nav a').should('have.length', 5);
    cy.get('nav a').contains('Home').click();
    cy.url().should('include', 'index.html');
  });

  it('Should return 404 for various invalid paths', () => {
    const invalidPaths = [
      '/invalid/path',
      '/about/non-existent',
      '/portfolio/fake-project.html',
      '/research/missing-page',
    ];

    invalidPaths.forEach((path) => {
      cy.request({ url: path, failOnStatusCode: false }).then((response) => {
        expect(response.status).to.eq(404);
      });
    });
  });
});
