import React from 'react';
import HeaderBox from '../HeaderBox';
import PortfolioBox from '../PortfolioBox';
import YouTubeBox from '../YouTubeBox';
import DiscordBox from '../DiscordBox';
import styles from './HomepagePanels.module.css';

/**
 * HomepagePanels - Parent widget that groups all homepage panel cards.
 * Add, remove or reorder panels here to manage the header section layout.
 */
const HomepagePanels = () => {
  return (
    <div className={styles.panelsGrid}>
      <HeaderBox />
      <PortfolioBox />
      <YouTubeBox />
      <DiscordBox />
    </div>
  );
};

export default HomepagePanels;
