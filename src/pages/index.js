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
import PortfolioBox from '../components/PortfolioBox';
import HeaderBox from '../components/HeaderBox';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className={styles.headerContainer}>
        <HeaderBox />
        <PortfolioBox />
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