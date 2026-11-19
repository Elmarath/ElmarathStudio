// Search scoring, the same as the Flutter site's: a title match beats a
// heading match beats a text match, and every word typed has to match.
// Shared by the browser (search dialog) and the tests.

export interface RawEntry {
  kind: 'doc' | 'post' | 'page' | 'work';
  title: string;
  context: string;
  route: string;
  headings: string;
  text: string;
}

export interface IndexedEntry extends RawEntry {
  score(terms: string[]): number;
  snippet(term: string | undefined): string;
}

export function searchEntries(raw: RawEntry[]): IndexedEntry[] {
  return raw.map((e) => {
    const title = e.title.toLowerCase();
    const headings = e.headings.toLowerCase();
    const text = e.text.toLowerCase();
    return {
      ...e,
      score(terms: string[]) {
        let score = 0;
        for (const term of terms) {
          if (title.includes(term)) score += 10;
          else if (headings.includes(term)) score += 4;
          else if (text.includes(term)) score += 1;
          else return 0;
        }
        return score;
      },
      snippet(term: string | undefined) {
        const at = term ? text.indexOf(term) : -1;
        if (at < 0) return e.text.length > 120 ? `${e.text.slice(0, 120)}…` : e.text;
        const start = Math.max(0, at - 50);
        const end = Math.min(e.text.length, at + 90);
        return `${start > 0 ? '…' : ''}${e.text.slice(start, end)}${end < e.text.length ? '…' : ''}`;
      },
    };
  });
}

const escape = (s: string) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);

/** [text] as HTML with the [terms] marked. */
export function highlight(text: string, terms: string[]): string {
  const safe = escape(text);
  const words = terms.filter((t) => t.length > 1).map((t) => escape(t).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  if (words.length === 0) return safe;
  return safe.replace(new RegExp(`(${words.join('|')})`, 'gi'), '<mark>$1</mark>');
}
