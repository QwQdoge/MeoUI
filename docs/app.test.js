/** @jest-environment jsdom */

const fs = require('fs');
const path = require('path');

describe('MeoUI-SpecSite app.js', () => {
  let tokenSections;
  let components;

  beforeEach(() => {
    document.documentElement.innerHTML = fs.readFileSync(
      path.resolve(__dirname, 'index.html'),
      'utf8'
    );

    tokenSections = {
      typography: [
        ["typefaceBrand", "Comfortaa Bold", "Brand name"],
        ["titleBig", "Comfortaa Bold 40 / 48", "Page title"]
      ],
      motion: [
        ["motionDurationFast", "150", "Hover, color"]
      ]
    };

    components = [
      ["Atomic", "MeoButton", "Command button"],
      ["Atomic", "MeoIcon", "Material Symbols"],
      ["Inputs", "MeoTextField", "Single-line text input"]
    ];

    const appJsCode = fs.readFileSync(path.resolve(__dirname, 'app.js'), 'utf8');
    Function('tokenSections', 'components', appJsCode)(tokenSections, components);
  });

  it('renders typography tokens by default', () => {
    const tokenTable = document.querySelector("#token-table");
    expect(tokenTable.innerHTML).toContain('typefaceBrand');
    expect(tokenTable.innerHTML).toContain('Comfortaa Bold');
  });

  it('changes tokens when a tab is clicked', () => {
    const motionTab = document.querySelector('[data-token-tab="motion"]');
    motionTab.click();

    const tokenTable = document.querySelector("#token-table");
    expect(tokenTable.innerHTML).toContain('motionDurationFast');
    expect(tokenTable.innerHTML).not.toContain('typefaceBrand');
  });

  it('renders all categories in the filter', () => {
    const categoryFilter = document.querySelector("#category-filter");
    expect(categoryFilter.innerHTML).toContain('<option value="全部">全部</option>');
    expect(categoryFilter.innerHTML).toContain('<option value="Atomic">Atomic</option>');
    expect(categoryFilter.innerHTML).toContain('<option value="Inputs">Inputs</option>');
  });

  it('renders all components initially', () => {
    const grid = document.querySelector("#component-grid");
    expect(grid.innerHTML).toContain('MeoButton');
    expect(grid.innerHTML).toContain('MeoIcon');
    expect(grid.innerHTML).toContain('MeoTextField');
  });

  it('filters components by search query', () => {
    const search = document.querySelector("#component-search");
    search.value = 'textfield';
    search.dispatchEvent(new window.Event('input'));

    const grid = document.querySelector("#component-grid");
    expect(grid.innerHTML).toContain('MeoTextField');
    expect(grid.innerHTML).not.toContain('MeoButton');
  });

  it('filters components by category', () => {
    const categoryFilter = document.querySelector("#category-filter");
    categoryFilter.value = 'Inputs';
    categoryFilter.dispatchEvent(new window.Event('change'));

    const grid = document.querySelector("#component-grid");
    expect(grid.innerHTML).toContain('MeoTextField');
    expect(grid.innerHTML).not.toContain('MeoButton');
  });
});
