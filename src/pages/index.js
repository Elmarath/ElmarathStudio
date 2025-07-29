import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import styles from './index.module.css';
import HomepageDocumentPreviews from '../components/HomepageDocumentPreviews';
import React from 'react';
import HireBox from '../components/HireBox';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className={styles.headerBox}>
        <img
          src={require('@site/static/img/T_ElmarathLogo.png').default}
          alt="Elmarath Studio Logo"
          className={styles.logo}
        />
        <div className={styles.headerText}>
          <h1 className={styles.siteTitle}>{siteConfig.title}</h1>
          <p className={styles.description}>{"Game and Game Tools Development"}</p>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Game and Game Tools Development">
      <HomepageHeader />
      <main>
        <HomepageDocumentPreviews />
        <hr />
        <HomepageFeatures />
      </main>
    </Layout>
  );
}