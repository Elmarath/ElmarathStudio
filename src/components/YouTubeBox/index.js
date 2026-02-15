import React, { useState } from 'react';
import HeaderCard from '../HeaderCard';
import styles from './YouTubeBox.module.css';

const YouTubeBox = () => {
  const [isHovered, setIsHovered] = useState(false);

  const handleClick = () => {
    window.open('https://www.youtube.com/@Elmarath', '_blank');
  };

  return (
    <HeaderCard 
      onClick={handleClick}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div className={styles.youtubeHeader}>
        <svg className={styles.youtubeIcon} viewBox="0 0 24 24" fill="currentColor">
          <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
        </svg>
      </div>
      
      <h3 className={styles.channelName}>@Elmarath</h3>
      <p className={styles.callToAction}>Watch the plugin documentation, showcases, devlogs and more!</p>
      
      <div className={styles.subscribeButton}>
        <svg className={styles.bellIcon} viewBox="0 0 24 24" fill="currentColor">
          <path d="M10 20h4c0 1.1-.9 2-2 2s-2-.9-2-2zm10-6v-3c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C9.63 5.36 8 7.92 8 11v3l-2 2v1h12v-1l-2-2z"/>
        </svg>
        Subscribe for Updates
      </div>
      
      {isHovered && <div className={styles.glowEffect}></div>}
    </HeaderCard>
  );
};

export default YouTubeBox;
