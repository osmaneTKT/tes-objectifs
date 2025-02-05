const backdrop = document.querySelector('.backdrop');
const sideDrawer = document.querySelector('.mobile-nav');
const menuToggle = document.querySelector('#side-menu-toggle');

function closeMenu() {
  backdrop.classList.remove('visible');
  sideDrawer.classList.remove('open');
  setTimeout(() => {
    backdrop.style.display = 'none';
  }, 300);
}

function openMenu() {
  backdrop.style.display = 'block';
  setTimeout(() => {
    backdrop.classList.add('visible');
    sideDrawer.classList.add('open');
  }, 10);
}

backdrop.addEventListener('click', closeMenu);
menuToggle.addEventListener('click', openMenu);

// Ensure smooth transition
document.addEventListener('DOMContentLoaded', () => {
  backdrop.style.transition = 'opacity 0.3s ease-in-out';
  sideDrawer.style.transition = 'transform 0.3s ease-in-out';
});
