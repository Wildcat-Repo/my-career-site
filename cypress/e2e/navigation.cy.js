/// <reference types="cypress" />

describe('Navigation Tests', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('TC-NAV-001: Should load the home page', () => {
    cy.url().should('include', 'localhost:8000');
    cy.title().should('contain', 'Theron Blount');
    cy.get('h1').should('contain', 'Welcome');
  });

  it('TC-NAV-002: Should navigate to About page', () => {
    cy.get('nav a').contains('About').click();
    cy.url().should('include', '/about');
    cy.title().should('contain', 'About');
    cy.get('nav a[aria-current="page"]').should('not.exist');
  });

  it('TC-NAV-003: Should navigate to Portfolio page', () => {
    cy.get('nav a').contains('Portfolio').click();
    cy.url().should('include', '/portfolio');
    cy.title().should('contain', 'Portfolio');
    cy.get('h1').should('contain', 'Portfolio Projects');
  });

  it('TC-NAV-004: Should navigate to Research page', () => {
    cy.get('nav a').contains('Research').click();
    cy.url().should('include', '/research');
    cy.title().should('contain', 'Research');
    cy.get('h1').should('contain', 'Research');
  });

  it('TC-NAV-005: Should navigate to Contact page', () => {
    cy.get('nav a').contains('Contact').click();
    cy.url().should('include', '/contact');
    cy.title().should('contain', 'Contact');
    cy.get('h1').should('contain', 'Contact Me');
  });

  it('TC-NAV-006: Should navigate back to home from any page', () => {
    cy.get('nav a').contains('About').click();
    cy.get('nav a').contains('Home').click();
    cy.url().should('eq', Cypress.config().baseUrl + '/');
  });

  it('TC-NAV-007: Should have active page indicator on home', () => {
    cy.get('nav a[aria-current="page"]').should('contain', 'Home');
  });

  it('TC-NAV-008: Should navigate between all pages in sequence', () => {
    const pages = ['About', 'Portfolio', 'Research', 'Contact'];
    
    pages.forEach((page) => {
      cy.get('nav a').contains(page).click();
      cy.url().should('include', page.toLowerCase());
    });
  });

  it('TC-NAV-009: Should have all navigation links on every page', () => {
    const pages = ['/', '/about/', '/portfolio/', '/research/', '/contact/'];
    
    pages.forEach((page) => {
      cy.visit(page);
      cy.get('nav a').should('have.length', 5);
    });
  });
});
