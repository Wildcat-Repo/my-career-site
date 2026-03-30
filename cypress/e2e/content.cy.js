/// <reference types="cypress" />

describe('Page Content Validation Tests', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  describe('Home Page Content', () => {
    it('TC-CONTENT-001: Should display welcome message', () => {
      cy.get('h1').should('contain', 'Welcome');
      cy.get('main').should('contain', 'Thank you for visiting');
    });

    it('TC-CONTENT-007: Should have correct page title', () => {
      cy.title().should('eq', 'Theron Blount');
    });

    it('TC-CONTENT-006: Should have meta description', () => {
      cy.checkMetaDescription();
      cy.get('head meta[name="description"]')
        .should('have.attr', 'content')
        .and('include', 'Senior SDET');
    });
  });

  describe('About Page Content', () => {
    beforeEach(() => {
      cy.visit('/about/');
    });

    it('TC-CONTENT-002: Should display professional journey', () => {
      cy.get('h1').should('contain', 'Theron Blount');
      cy.get('.presentation').should('exist');
      cy.get('.section').should('have.length.at.least', 1);
    });

    it('TC-CONTENT-007: Should have correct page title', () => {
      cy.title().should('contain', 'About');
    });

    it('TC-CONTENT-006: Should have meta description', () => {
      cy.checkMetaDescription();
      cy.get('head meta[name="description"]')
        .should('have.attr', 'content')
        .and('include', 'professional journey');
    });

    it('Should display contact information', () => {
      cy.get('.contact-info').should('exist');
      cy.get('.contact-info').should('contain', 'tsblount@gmail.com');
    });
  });

  describe('Portfolio Page Content', () => {
    beforeEach(() => {
      cy.visit('/portfolio/');
    });

    it('TC-CONTENT-003: Should display project cards', () => {
      cy.get('h1').should('contain', 'Portfolio Projects');
      cy.get('.portfolio-grid').should('exist');
      cy.get('.project-card').should('have.length', 4);
    });

    it('TC-CONTENT-007: Should have correct page title', () => {
      cy.title().should('contain', 'Portfolio');
    });

    it('TC-CONTENT-006: Should have meta description', () => {
      cy.checkMetaDescription();
      cy.get('head meta[name="description"]')
        .should('have.attr', 'content')
        .and('include', 'Portfolio showcasing');
    });

    it('Should have project links', () => {
      cy.get('.project-card a').should('have.length', 4);
      cy.get('.project-card a').each(($link) => {
        cy.wrap($link).should('have.attr', 'href');
      });
    });

    it('Should display all four projects', () => {
      cy.get('.project-card').eq(0).should('contain', 'SpinJockey Network');
      cy.get('.project-card').eq(1).should('contain', 'Bookshare');
      cy.get('.project-card').eq(2).should('contain', 'NFL Sports Analytics');
      cy.get('.project-card').eq(3).should('contain', 'Development Server');
    });
  });

  describe('Research Page Content', () => {
    beforeEach(() => {
      cy.visit('/research/');
    });

    it('TC-CONTENT-004: Should load research content', () => {
      cy.get('h1').should('contain', 'Research');
      cy.get('main').should('exist');
    });

    it('TC-CONTENT-007: Should have correct page title', () => {
      cy.title().should('contain', 'Research');
    });

    it('TC-CONTENT-006: Should have meta description', () => {
      cy.checkMetaDescription();
      cy.get('head meta[name="description"]')
        .should('have.attr', 'content')
        .and('include', 'Research and technical articles');
    });
  });

  describe('Contact Page Content', () => {
    beforeEach(() => {
      cy.visit('/contact/');
    });

    it('TC-CONTENT-005: Should display email and social links', () => {
      cy.get('h1').should('contain', 'Contact Me');
      cy.get('a[href="mailto:tsblount@gmail.com"]').should('exist');
      cy.get('.social-media').should('exist');
    });

    it('TC-CONTENT-007: Should have correct page title', () => {
      cy.title().should('contain', 'Contact');
    });

    it('TC-CONTENT-006: Should have meta description', () => {
      cy.checkMetaDescription();
      cy.get('head meta[name="description"]')
        .should('have.attr', 'content')
        .and('include', 'Get in touch');
    });

    it('Should have all three social media links', () => {
      cy.get('.social-media__link').should('have.length', 3);
      cy.get('.social-media__label').contains('LinkedIn').should('exist');
      cy.get('.social-media__label').contains('GitHub').should('exist');
      cy.get('.social-media__label').contains('Twitter').should('exist');
    });
  });

  describe('Common Elements', () => {
    const pages = ['/', '/about/', '/portfolio/', '/research/', '/contact/'];

    pages.forEach((page) => {
      it(`Should have header and footer on ${page}`, () => {
        cy.visit(page);
        cy.checkCommonElements();
      });

      it(`Should have viewport meta tag on ${page}`, () => {
        cy.visit(page);
        cy.get('head meta[name="viewport"]').should('exist');
      });

      it(`Should have UTF-8 charset on ${page}`, () => {
        cy.visit(page);
        cy.get('head meta[charset]').should('have.attr', 'charset', 'UTF-8');
      });
    });
  });
});
