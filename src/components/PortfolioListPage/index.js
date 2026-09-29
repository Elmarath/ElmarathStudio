import React, {useMemo, useState} from 'react';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import PortfolioProjectCard from '../PortfolioProjectCard';
import styles from './PortfolioListPage.module.css';

export default function PortfolioListPage({metadata, items}) {
  const [search, setSearch] = useState('');
  const [activeTag, setActiveTag] = useState('');

  const tags = useMemo(
    () =>
      [...new Map(
        items.flatMap(({content}) =>
          content.metadata.tags.map((tag) => [tag.label, tag]),
        ),
      ).values()].sort((a, b) => a.label.localeCompare(b.label)),
    [items],
  );

  const normalizedSearch = search.trim().toLocaleLowerCase();
  const filteredItems = items.filter(({content}) => {
    const post = content.metadata;
    const matchesSearch =
      !normalizedSearch ||
      [post.title, post.description, ...post.tags.map((tag) => tag.label)]
        .join(' ')
        .toLocaleLowerCase()
        .includes(normalizedSearch);
    const matchesTag =
      !activeTag || post.tags.some((tag) => tag.label === activeTag);

    return matchesSearch && matchesTag;
  });

  const clearFilters = () => {
    setSearch('');
    setActiveTag('');
  };

  return (
    <Layout title={metadata.blogTitle} description={metadata.blogDescription}>
      <main className="container margin-vert--lg">
        <header className={styles.header}>
          <h1>{metadata.blogTitle}</h1>
          <p>{metadata.blogDescription}</p>
        </header>
        <section className={styles.filters} aria-label="Search and filter projects">
          <label className={styles.searchLabel}>
            <span>Search projects</span>
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search by project or topic"
              className={styles.searchInput}
            />
          </label>
          <div className={styles.filterGroup}>
            <span className={styles.filterLabel}>Filter by topic</span>
            <div className={styles.filterOptions} role="group" aria-label="Filter projects by topic">
              <button
                type="button"
                className={`${styles.filterButton} ${activeTag === '' ? styles.activeFilter : ''}`}
                aria-pressed={activeTag === ''}
                onClick={() => setActiveTag('')}
              >
                All
              </button>
              {tags.map((tag) => (
                <button
                  key={tag.permalink}
                  type="button"
                  className={`${styles.filterButton} ${activeTag === tag.label ? styles.activeFilter : ''}`}
                  aria-pressed={activeTag === tag.label}
                  onClick={() => setActiveTag(tag.label)}
                >
                  {tag.label}
                </button>
              ))}
            </div>
          </div>
          <p className={styles.resultCount} aria-live="polite">
            {filteredItems.length} {filteredItems.length === 1 ? 'project' : 'projects'}
          </p>
        </section>
        <div className={styles.grid} id="projects">
          {filteredItems.map(({content}) => {
            const post = content.metadata;
            return <PortfolioProjectCard key={post.permalink} post={post} />;
          })}
        </div>
        {filteredItems.length === 0 && (
          <div className={styles.emptyState}>
            <h2>No projects found</h2>
            <p>Try a different search or clear your filters.</p>
            <button type="button" className={styles.resetButton} onClick={clearFilters}>
              Clear search and filters
            </button>
          </div>
        )}
      </main>
    </Layout>
  );
}
