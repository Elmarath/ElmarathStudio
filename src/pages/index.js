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

// Simple animated connector with thin fading line
function AnimatedConnector() {
  return (
    <div className={styles.connectorSection}>
      {/* Simple thin fading line with center animation */}
      <div className={styles.simpleLine}>
        <div className={styles.lineLeft}></div>
        <div className={styles.centerPulse}>
          <div className={styles.pulseRing}></div>
        </div>
        <div className={styles.lineRight}></div>
      </div>
    </div>
  );
}

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
      <AnimatedConnector />
      <main>
        <HomepageDocumentPreviews />
        <hr />
        <HomepageFeatures />
      </main>
    </Layout>
  );
}