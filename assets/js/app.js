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

const imageButtons = document.querySelectorAll('.product-media-btn');

if (imageButtons.length) {
  const lightbox = document.createElement('div');
  lightbox.className = 'image-lightbox';
  lightbox.innerHTML = `
    <div class="lightbox-inner">
      <button type="button" class="lightbox-close" aria-label="Close image viewer">&times;</button>
      <img class="lightbox-img" src="" alt="">
    </div>
  `;

  document.body.appendChild(lightbox);

  const lightboxImg = lightbox.querySelector('.lightbox-img');
  const closeBtn = lightbox.querySelector('.lightbox-close');

  const closeLightbox = () => {
    lightbox.classList.remove('open');
    lightboxImg.src = '';
    lightboxImg.alt = '';
  };

  imageButtons.forEach(button => {
<<<<<<< ours
    button.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();

      const src = button.dataset.imageSrc || button.querySelector('img')?.getAttribute('src') || '';
      const alt = button.dataset.imageAlt || 'Product image';

      if (!src) return;

      lightboxImg.src = src;
      lightboxImg.alt = alt;
=======
    button.addEventListener('click', () => {
      lightboxImg.src = button.dataset.imageSrc || '';
      lightboxImg.alt = button.dataset.imageAlt || 'Product image';
>>>>>>> theirs
      lightbox.classList.add('open');
    });
  });

  closeBtn.addEventListener('click', closeLightbox);
  lightbox.addEventListener('click', (event) => {
    if (event.target === lightbox) closeLightbox();
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && lightbox.classList.contains('open')) {
      closeLightbox();
    }
  });
}
