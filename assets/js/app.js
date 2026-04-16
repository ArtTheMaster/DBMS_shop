const themeToggle = document.getElementById('themeToggle');
const body = document.body;
const savedTheme = localStorage.getItem('artshop-theme');
if (savedTheme === 'dark') body.classList.add('dark');

if (themeToggle) {
  themeToggle.addEventListener('click', () => {
    body.classList.toggle('dark');
    localStorage.setItem('artshop-theme', body.classList.contains('dark') ? 'dark' : 'light');
  });
}

const chips = document.querySelectorAll('.filter-chip');
const cards = document.querySelectorAll('.product');
chips.forEach(chip => {
  chip.addEventListener('click', () => {
    chips.forEach(c => c.classList.remove('active'));
    chip.classList.add('active');
    const target = chip.dataset.filter;

    cards.forEach(card => {
      card.style.display = (target === 'All' || card.dataset.category === target) ? 'flex' : 'none';
    });
  });
});
