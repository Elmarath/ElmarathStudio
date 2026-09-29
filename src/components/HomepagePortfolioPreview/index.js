import React from 'react';
import Link from '@docusaurus/Link';
import {usePluginData} from '@docusaurus/useGlobalData';
import PortfolioProjectCard from '../PortfolioProjectCard';
import styles from './HomepagePortfolioPreview.module.css';
import portfolioStyles from '../PortfolioListPage/PortfolioListPage.module.css';

export default function HomepagePortfolioPreview() {
  const {projects} = usePluginData('portfolio-home-data');
  const latestProjects = projects.slice(0, 4);

  return (
    <section className={styles.section} aria-labelledby="homepage-portfolio-title">
      <div className={styles.container}>
        <header className={styles.header}>
          <h2 id="homepage-portfolio-title">Portfolio</h2>
          <Link to="/portfolio" className={styles.viewAll}>
            View all
          </Link>
        </header>
        <div className={portfolioStyles.grid}>
          {latestProjects.map((project) => (
            <PortfolioProjectCard key={project.permalink} post={project} />
          ))}
        </div>
      </div>
    </section>
  );
}
