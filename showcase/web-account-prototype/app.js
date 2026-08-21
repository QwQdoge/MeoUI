const root = document.documentElement;
const loginView = document.querySelector('#loginView');
const accountView = document.querySelector('#accountView');
const themeToggle = document.querySelector('#themeToggle');
const loginForm = document.querySelector('#loginForm');
const emailField = document.querySelector('#emailField');
const passwordField = document.querySelector('#passwordField');
const accountChip = document.querySelector('#accountChip');
const accountEmail = document.querySelector('#accountEmail');
const emailInput = document.querySelector('#email');
const continueButton = document.querySelector('#continueButton span');
const authTitle = document.querySelector('#authTitle');
const authSupporting = document.querySelector('#authSupporting');
const changeEmail = document.querySelector('#changeEmail');
const overviewSection = document.querySelector('#overviewSection');
const genericSection = document.querySelector('#genericSection');
const genericTitle = document.querySelector('#genericTitle');
const genericBody = document.querySelector('#genericBody');
const genericIconUse = document.querySelector('#genericIcon use');
const sectionTitle = document.querySelector('#sectionTitle');

const sectionCopy = {
  profile: {
    title: 'Profile',
    body: 'Personal information, avatar, profile visibility and recovery contact settings belong here.',
    icon: '#i-person',
  },
  security: {
    title: 'Security Center',
    body: 'Password, MFA, recent security events and session-bound step-up verification are designed here before production implementation.',
    icon: '#i-shield',
  },
  devices: {
    title: 'Devices',
    body: 'Review current and recent sessions, identify the active session and revoke other devices through the protected account-security boundary.',
    icon: '#i-device',
  },
  apps: {
    title: 'Apps & data',
    body: 'Connected MeoArch services, synced application state, library snapshots and data controls share one consistent account surface.',
    icon: '#i-apps',
  },
  settings: {
    title: 'Settings',
    body: 'Language, appearance, notifications and account-level preferences are grouped here without mixing them into security controls.',
    icon: '#i-settings',
  },
};

function setTheme(theme) {
  if (theme === 'dark') root.dataset.theme = 'dark';
  else delete root.dataset.theme;
  localStorage.setItem('meo-account-prototype-theme', theme);
}

const savedTheme = localStorage.getItem('meo-account-prototype-theme');
if (savedTheme) setTheme(savedTheme);
else if (matchMedia('(prefers-color-scheme: dark)').matches) setTheme('dark');

themeToggle.addEventListener('click', () => {
  setTheme(root.dataset.theme === 'dark' ? 'light' : 'dark');
});

function resetLogin() {
  emailField.classList.remove('hidden');
  passwordField.classList.add('hidden');
  accountChip.classList.add('hidden');
  continueButton.textContent = 'Continue';
  authTitle.textContent = 'Sign in to MeoArch';
  authSupporting.textContent = 'Use your Meo Account to continue.';
}

function enterPasswordStep() {
  const email = emailInput.value.trim() || 'demo@meoarch.org';
  accountEmail.textContent = email;
  emailField.classList.add('hidden');
  passwordField.classList.remove('hidden');
  accountChip.classList.remove('hidden');
  continueButton.textContent = 'Sign in';
  authTitle.textContent = 'Welcome back';
  authSupporting.textContent = 'Enter your password to continue.';
  requestAnimationFrame(() => document.querySelector('#password')?.focus());
}

function enterAccount() {
  loginView.classList.add('hidden');
  accountView.classList.remove('hidden');
  window.scrollTo({ top: 0, behavior: 'instant' });
  showSection('overview');
}

loginForm.addEventListener('submit', (event) => {
  event.preventDefault();
  if (passwordField.classList.contains('hidden')) enterPasswordStep();
  else enterAccount();
});

changeEmail.addEventListener('click', () => {
  resetLogin();
  requestAnimationFrame(() => emailInput.focus());
});

document.querySelectorAll('[data-oauth]').forEach((button) => {
  button.addEventListener('click', enterAccount);
});

document.querySelector('.create-account')?.addEventListener('click', () => {
  resetLogin();
  authTitle.textContent = 'Create your Meo Account';
  authSupporting.textContent = 'This prototype reuses the same shell for sign-up exploration.';
  emailInput.focus();
});

function showSection(section) {
  const isOverview = section === 'overview';
  overviewSection.classList.toggle('hidden', !isOverview);
  genericSection.classList.toggle('hidden', isOverview);

  if (isOverview) {
    sectionTitle.textContent = 'Overview';
  } else {
    const copy = sectionCopy[section] ?? sectionCopy.profile;
    sectionTitle.textContent = copy.title;
    genericTitle.textContent = copy.title;
    genericBody.textContent = copy.body;
    genericIconUse.setAttribute('href', copy.icon);
  }

  document.querySelectorAll('[data-section]').forEach((button) => {
    button.classList.toggle('active', button.dataset.section === section);
  });
}

document.querySelectorAll('[data-section]').forEach((button) => {
  button.addEventListener('click', () => showSection(button.dataset.section));
});

document.querySelectorAll('[data-nav-to]').forEach((button) => {
  button.addEventListener('click', () => showSection(button.dataset.navTo));
});

document.querySelector('#signOutButton')?.addEventListener('click', () => {
  accountView.classList.add('hidden');
  loginView.classList.remove('hidden');
  resetLogin();
  window.scrollTo({ top: 0, behavior: 'instant' });
});
