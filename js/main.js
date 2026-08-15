/* ==========================================================================
   IDEAL SPORTS — Shared JavaScript Engine
   Vanilla ES6+ | requestAnimationFrame | IntersectionObserver
   ========================================================================== */

'use strict';

/* --------------------------------------------------------------------------
   1. STICKY HEADER — Scroll Shadow Effect
   -------------------------------------------------------------------------- */
const initHeader = () => {
  const header = document.querySelector('.header');
  if (!header) return;

  const onScroll = () => {
    header.classList.toggle('scrolled', window.scrollY > 10);
  };

  // Passive listener for maximum scroll performance
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
};

/* --------------------------------------------------------------------------
   2. MOBILE DRAWER NAVIGATION — Slide-Out Menu
   -------------------------------------------------------------------------- */
const initMobileNav = () => {
  const hamburger = document.querySelector('.hamburger');
  const drawer = document.querySelector('.mobile-drawer');
  const overlay = document.querySelector('.drawer-overlay');
  if (!hamburger || !drawer || !overlay) return;

  const closeDrawer = () => {
    hamburger.classList.remove('active');
    drawer.classList.remove('open');
    overlay.classList.remove('show');
    document.body.style.overflow = '';
  };

  const openDrawer = () => {
    hamburger.classList.add('active');
    drawer.classList.add('open');
    overlay.classList.add('show');
    document.body.style.overflow = 'hidden';
  };

  hamburger.addEventListener('click', () => {
    drawer.classList.contains('open') ? closeDrawer() : openDrawer();
  });

  overlay.addEventListener('click', closeDrawer);

  // Close drawer when a nav link is clicked
  drawer.querySelectorAll('.nav-link').forEach((link) => {
    link.addEventListener('click', closeDrawer);
  });

  // Close on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeDrawer();
  });
};

/* --------------------------------------------------------------------------
   3. INFINITE LIVE SCORE TICKER
   Uses requestAnimationFrame for 60fps smooth scrolling.
   Duplicate-clones content for a seamless infinite loop.
   Pauses on hover.
   -------------------------------------------------------------------------- */
const initTicker = () => {
  const track = document.querySelector('.ticker-track');
  if (!track) return;

  // Clone the entire track content once for seamless looping
  const clone = track.innerHTML;
  track.innerHTML += clone;

  let position = 0;
  let speed = 0.8; // px per frame
  let paused = false;
  let lastTime = 0;
  let animationId = null;

  const tickerWrap = track.closest('.ticker-wrap');

  // Pause on hover / resume on leave
  tickerWrap.addEventListener('mouseenter', () => { paused = true; });
  tickerWrap.addEventListener('mouseleave', () => { paused = false; });

  // Pause when tab is hidden to save resources
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      paused = true;
    } else {
      paused = false;
    }
  });

  const animate = (timestamp) => {
    // Throttle to ~60fps using delta time
    if (!lastTime) lastTime = timestamp;
    const delta = timestamp - lastTime;
    lastTime = timestamp;

    if (!paused) {
      // Normalize speed by delta time (target 60fps)
      position -= speed * (delta / 16.67);

      const halfWidth = track.scrollWidth / 2;
      // Reset position when we've scrolled past one full clone
      if (Math.abs(position) >= halfWidth) {
        position += halfWidth;
      }

      // Hardware-accelerated transform
      track.style.transform = `translate3d(${position}px, 0, 0)`;
    }

    animationId = requestAnimationFrame(animate);
  };

  animationId = requestAnimationFrame(animate);

  // Cleanup on page unload
  window.addEventListener('beforeunload', () => {
    if (animationId) cancelAnimationFrame(animationId);
  });
};

/* --------------------------------------------------------------------------
   4. STAGGERED SCROLL-REVEAL ENGINE
   IntersectionObserver + CSS transitions for smooth fade/slide-up.
   -------------------------------------------------------------------------- */
const initScrollReveal = () => {
  const revealElements = document.querySelectorAll('.reveal');
  if (!revealElements.length) return;

  // Respect reduced motion — reveal everything immediately
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    revealElements.forEach((el) => el.classList.add('visible'));
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          // Unobserve after reveal for performance
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.12,
      rootMargin: '0px 0px -40px 0px',
    }
  );

  revealElements.forEach((el) => observer.observe(el));
};

/* --------------------------------------------------------------------------
   5. ANIMATED STAT COUNTER
   IntersectionObserver triggers a requestAnimationFrame count-up animation.
   Supports decimals, suffixes, and prefix symbols.
   -------------------------------------------------------------------------- */
const initStatCounters = () => {
  const counters = document.querySelectorAll('[data-counter]');
  if (!counters.length) return;

  // Respect reduced motion — set final values instantly
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    counters.forEach((el) => {
      el.textContent = el.dataset.counter;
    });
    return;
  }

  const easeOutExpo = (t) => (t === 1 ? 1 : 1 - Math.pow(2, -10 * t));

  const animateCounter = (el) => {
    const target = parseFloat(el.dataset.counter);
    const decimals = (el.dataset.decimals) ? parseInt(el.dataset.decimals, 10) : 0;
    const duration = parseInt(el.dataset.duration || '2000', 10);
    const prefix = el.dataset.prefix || '';
    const suffix = el.dataset.suffix || '';

    let startTime = null;

    const step = (timestamp) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / duration, 1);
      const eased = easeOutExpo(progress);
      const current = target * eased;

      el.textContent = prefix + current.toFixed(decimals) + suffix;

      if (progress < 1) {
        requestAnimationFrame(step);
      } else {
        // Ensure exact final value
        el.textContent = prefix + target.toFixed(decimals) + suffix;
      }
    };

    requestAnimationFrame(step);
  };

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.4 }
  );

  counters.forEach((el) => observer.observe(el));
};

/* --------------------------------------------------------------------------
   6. ACTIVE NAV LINK HIGHLIGHTING
   -------------------------------------------------------------------------- */
const initActiveNav = () => {
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-link').forEach((link) => {
    const href = link.getAttribute('href');
    if (href === currentPage) {
      link.classList.add('active');
    }
  });
};

/* --------------------------------------------------------------------------
   7. INITIALIZE ALL SHARED MODULES
   -------------------------------------------------------------------------- */
document.addEventListener('DOMContentLoaded', () => {
  initHeader();
  initMobileNav();
  initTicker();
  initScrollReveal();
  initStatCounters();
  initActiveNav();
});