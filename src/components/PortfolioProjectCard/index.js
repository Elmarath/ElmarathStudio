import React, {useState} from 'react';
import Link from '@docusaurus/Link';
import styles from '../PortfolioListPage/PortfolioListPage.module.css';

export default function PortfolioProjectCard({post}) {
  const image = post.frontMatter.image;
  const [isPortrait, setIsPortrait] = useState(false);
  const date = new Intl.DateTimeFormat('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(new Date(post.date));

  return (
    <article className={styles.card}>
      <Link to={post.permalink} className={styles.imageLink}>
        {image ? (
          <img
            className={`${styles.image} ${isPortrait ? styles.portraitImage : ''}`}
            src={image}
            alt={`${post.title} project thumbnail`}
            onLoad={(event) => {
              const {naturalWidth, naturalHeight} = event.currentTarget;
              setIsPortrait(naturalHeight > naturalWidth);
            }}
          />
        ) : (
          <div className={styles.imagePlaceholder} aria-hidden="true" />
        )}
      </Link>
      <div className={styles.cardContent}>
        <time className={styles.date} dateTime={post.date}>
          {date}
        </time>
        <h2 className={styles.title}>
          <Link to={post.permalink}>{post.title}</Link>
        </h2>
        <p className={styles.description}>{post.description}</p>
        <div className={styles.tags}>
          {post.tags.map((tag) => (
            <Link key={tag.permalink} to={tag.permalink} className={styles.tag}>
              {tag.label}
            </Link>
          ))}
        </div>
      </div>
    </article>
  );
}
