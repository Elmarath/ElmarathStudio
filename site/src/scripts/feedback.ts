// The "Was this useful?" box on posts and docs (src/components/Feedback.astro).
// A thumb picks the rating and can be switched until it's sent; Send posts one
// Netlify Forms entry with the rating and the optional comment. If the reader
// picks a thumb but leaves without sending, the rating still goes, once, as
// the page is left. Netlify takes form posts to any page of the site; "/"
// keeps it simple.
import { onPage } from './lifecycle.ts';

const body = (form: HTMLFormElement) =>
  new URLSearchParams(new FormData(form) as unknown as Record<string, string>).toString();

onPage((signal) => {
  for (const form of document.querySelectorAll<HTMLFormElement>('[data-feedback]')) {
    const $ = <T extends HTMLElement>(sel: string) => form.querySelector<T>(sel)!;
    const rating = $<HTMLInputElement>('input[name="rating"]');
    const comment = $<HTMLTextAreaElement>('textarea[name="comment"]');
    const more = $('[data-more]');
    const ask = $('[data-ask]');
    const done = $('[data-done]');
    const error = $('[data-error]');
    const send = $<HTMLButtonElement>('[data-send]');
    const thumbs = [...form.querySelectorAll<HTMLButtonElement>('button[data-rating]')];
    let sent = false;

    for (const thumb of thumbs) {
      thumb.addEventListener('click', () => {
        if (sent) return;
        rating.value = thumb.value;
        thumbs.forEach((t) => t.setAttribute('aria-pressed', String(t === thumb)));
        const opening = more.hidden;
        more.hidden = false;
        if (opening) comment.focus({ preventScroll: true });
      }, { signal });
    }

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      if (sent || !rating.value) return;
      send.disabled = true;
      error.hidden = true;
      fetch('/', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: body(form) })
        .then((r) => {
          if (!r.ok) throw new Error(String(r.status));
          sent = true;
          ask.hidden = true;
          more.hidden = true;
          done.hidden = false;
        })
        .catch(() => {
          send.disabled = false;
          error.hidden = false;
        });
    }, { signal });

    // Picked a thumb but never pressed Send: keep the rating anyway.
    const leave = () => {
      if (sent || !rating.value) return;
      sent = true;
      navigator.sendBeacon('/', new Blob([body(form)], { type: 'application/x-www-form-urlencoded' }));
    };
    addEventListener('pagehide', leave, { signal });
    signal.addEventListener('abort', leave);
  }
});
