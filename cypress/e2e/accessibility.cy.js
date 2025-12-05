/// <reference types="cypress" />

describe('Accessibility Tests', () => {
  const pages = [
    { path: '/', name: 'Home' },
    { path: '/about/', name: 'About' },
    { path: '/portfolio/', name: 'Portfolio' },
    { path: '/research/', name: 'Research' },
    { path: '/contact/', name: 'Contact' },
  ];

  pages.forEach((page) => {
    describe(`${page.name} Page Accessibility`, () => {
      beforeEach(() => {
        cy.visit(page.path);
      });

      it(`TC-A11Y-001: Should have skip-to-main-content link on ${page.name}`, () => {
        cy.checkSkipLink();
      });

      it(`TC-A11Y-002: Skip link should have correct href on ${page.name}`, () => {
        cy.get('a.skip-to-main').should('have.attr', 'href', '#main-content');
      });

      it(`TC-A11Y-003: Main content should have id attribute on ${page.name}`, () => {
        cy.get('#main-content').should('exist');
      });

      it(`TC-A11Y-004: Navigation should use semantic HTML on ${page.name}`, () => {
        cy.get('header nav').should('exist');
        cy.get('nav a').should('have.length.at.least', 5);
      });

      it(`TC-A11Y-005: Should have proper heading hierarchy on ${page.name}`, () => {
        cy.get('h1').should('have.length.at.least', 1);
      });

      it(`TC-A11Y-006: Footer should be present on ${page.name}`, () => {
        cy.get('footer').should('be.visible');
      });
    });
  });

  it('TC-A11Y-007: Active page should have aria-current attribute', () => {
    cy.visit('/');
    cy.get('nav a[aria-current="page"]').should('contain', 'Home');

    cy.visit('/portfolio/');
    cy.get('nav a[aria-current="page"]').should('contain', 'Portfolio');
  });

  it('TC-A11Y-008: All links should be keyboard accessible', () => {
    cy.visit('/');
    cy.get('nav a').first().focus().should('have.focus');
  });

  it('TC-A11Y-009: Skip link should be styled to appear on focus', () => {
    cy.visit('/');
    cy.get('a.skip-to-main').should('have.css', 'position', 'absolute');
  });

  it('TC-A11Y-010: Contact page social links should have proper aria labels', () => {
    cy.visit('/contact/');
    cy.get('.social-media__link').should('have.length.at.least', 3);
    cy.get('.social-media__link').each(($link) => {
      cy.wrap($link).should('have.attr', 'aria-label');
    });
  });
});
