// The "Was this useful?" box on posts and docs (src/components/Feedback.astro):
// sends the rating to Netlify Forms as soon as a thumb is clicked, then offers
// an optional comment. Netlify takes form posts to any page of the site; "/"
// keeps it simple.
import { onPage } from './lifecycle.ts';

const send = (form: HTMLFormElement, extra: Record<string, string>) => {
  const data = new FormData(form);
  for (const [k, v] of Object.entries(extra)) data.set(k, v);
  const body = new URLSearchParams(data as unknown as Record<string, string>).toString();
  return fetch('/', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body }).then((r) => {
    if (!r.ok) throw new Error(String(r.status));
  });
};

onPage((signal) => {
  for (const form of document.querySelectorAll<HTMLFormElement>('[data-feedback]')) {
    const $ = <T extends HTMLElement>(sel: string) => form.querySelector<T>(sel)!;
    const more = $('[data-more]');
    const done = $('[data-done]');
    const error = $('[data-error]');
    const thumbs = [...form.querySelectorAll<HTMLButtonElement>('button[data-rating]')];
    let rating = '';

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const button = (e as SubmitEvent).submitter as HTMLButtonElement | null;
      if (!button || rating) return;
      rating = button.value;
      thumbs.forEach((t) => {
        t.disabled = true;
        t.setAttribute('aria-pressed', String(t === button));
      });
      error.hidden = true;
      send(form, { rating, comment: '', step: 'rating' })
        .then(() => {
          more.hidden = false;
          form.querySelector('textarea')?.focus({ preventScroll: true });
        })
        .catch(() => {
          rating = '';
          thumbs.forEach((t) => {
            t.disabled = false;
            t.removeAttribute('aria-pressed');
          });
          error.hidden = false;
        });
    }, { signal });

    $<HTMLButtonElement>('[data-send]').addEventListener('click', (e) => {
      const button = e.currentTarget as HTMLButtonElement;
      const comment = form.querySelector('textarea')!.value.trim();
      if (!comment) {
        more.hidden = true;
        done.hidden = false;
        return;
      }
      button.disabled = true;
      error.hidden = true;
      send(form, { rating, comment, step: 'comment' })
        .then(() => {
          more.hidden = true;
          done.hidden = false;
        })
        .catch(() => {
          button.disabled = false;
          error.hidden = false;
        });
    }, { signal });
  }
});
