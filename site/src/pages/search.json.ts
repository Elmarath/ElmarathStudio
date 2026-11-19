// The search index: every doc, post, case study and page as plain text.
// Fetched the first time the search window opens.
import { content } from '../content/repository.ts';

export function GET() {
  return new Response(JSON.stringify(content().searchIndex), { headers: { 'Content-Type': 'application/json' } });
}
