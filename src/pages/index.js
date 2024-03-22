import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import Heading from '@theme/Heading';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ">
            Check Out Youtube Channel ▶️
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Game and Game Tools Development">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <div className={styles.buttons}>
          <Link
            className={`button button--secondary button--lg ${styles.customButton}`}
            to="/docs/intro">
            Go To Plug-In Documentations 📖
          </Link>
        </div>
        <div className={styles.customButtonContainer}>
          <Link
            className={`button button--primary button--lg ${styles.customButton}`}
            to="/docs/category/modular-action-system">
            Modular Action System
          </Link>
          <Link
            className={`button button--primary button--lg ${styles.customButton}`}
            to="/docs/category/modular-inventory-attachment-mia">
            Modular Inventory Attachment
          </Link>
        </div>
      </main>
    </Layout>
  );
}