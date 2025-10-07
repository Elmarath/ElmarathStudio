import React from 'react';
import { DOCUMENT_LIST } from '../../data';
import styles from './PluginLinks.module.css';

/**
 * PluginLinks Component - Displays relevant links for a plugin documentation page
 * Automatically finds and displays links based on the plugin ID
 */
const PluginLinks = ({ pluginId }) => {
  // Find the plugin data based on the ID
  const pluginData = DOCUMENT_LIST.find(plugin => 
    plugin.DocLink.includes(pluginId) || 
    plugin.title.toLowerCase().includes(pluginId.toLowerCase())
  );

  if (!pluginData) {
    return null; // Don't render if plugin not found
  }

  return (
    <div className={styles.pluginLinksContainer}>
      <h3 className={styles.linksTitle}>Quick Links</h3>
      <div className={styles.linksGrid}>
        
        {/* Fab Link (if available) */}
        {pluginData.FabLink && (
          <a 
            href={pluginData.FabLink} 
            target="_blank" 
            rel="noopener noreferrer"
            className={`${styles.linkButton} ${styles.fabButton}`}
            title="View on Fab"
          >
            <svg className={styles.linkIcon} viewBox="0 0 24 24" fill="currentColor">
              <path d="M12,2A2,2 0 0,1 14,4C14,4.74 13.6,5.39 13,5.73V7H14A7,7 0 0,1 21,14H22A1,1 0 0,1 23,15V18A1,1 0 0,1 22,19H21V20A2,2 0 0,1 19,22H5A2,2 0 0,1 3,20V19H2A1,1 0 0,1 1,18V15A1,1 0 0,1 2,14H3A7,7 0 0,1 10,7H11V5.73C10.4,5.39 10,4.74 10,4A2,2 0 0,1 12,2M7.5,13A2.5,2.5 0 0,0 5,15.5A2.5,2.5 0 0,0 7.5,18A2.5,2.5 0 0,0 10,15.5A2.5,2.5 0 0,0 7.5,13M16.5,13A2.5,2.5 0 0,0 14,15.5A2.5,2.5 0 0,0 16.5,18A2.5,2.5 0 0,0 19,15.5A2.5,2.5 0 0,0 16.5,13Z" />
            </svg>
            <span>Fab</span>
          </a>
        )}

        {/* GitHub Link (if available) */}
        {pluginData.GitHubLink && (
          <a 
            href={pluginData.GitHubLink} 
            target="_blank" 
            rel="noopener noreferrer"
            className={`${styles.linkButton} ${styles.githubButton}`}
            title="View on GitHub"
          >
            <svg className={styles.linkIcon} viewBox="0 0 24 24" fill="currentColor">
              <path d="M12,2A10,10 0 0,0 2,12C2,16.42 4.87,20.17 8.84,21.5C9.34,21.58 9.5,21.27 9.5,21C9.5,20.77 9.5,20.14 9.5,19.31C6.73,19.91 6.14,17.97 6.14,17.97C5.68,16.81 5.03,16.5 5.03,16.5C4.12,15.88 5.1,15.9 5.1,15.9C6.1,15.97 6.63,16.93 6.63,16.93C7.5,18.45 8.97,18 9.54,17.76C9.63,17.11 9.89,16.67 10.17,16.42C7.95,16.17 5.62,15.31 5.62,11.5C5.62,10.39 6,9.5 6.65,8.79C6.55,8.54 6.2,7.5 6.75,6.15C6.75,6.15 7.59,5.88 9.5,7.17C10.29,6.95 11.15,6.84 12,6.84C12.85,6.84 13.71,6.95 14.5,7.17C16.41,5.88 17.25,6.15 17.25,6.15C17.8,7.5 17.45,8.54 17.35,8.79C18,9.5 18.38,10.39 18.38,11.5C18.38,15.32 16.04,16.16 13.81,16.41C14.17,16.72 14.5,17.33 14.5,18.26C14.5,19.6 14.5,20.68 14.5,21C14.5,21.27 14.66,21.59 15.17,21.5C19.14,20.16 22,16.42 22,12A10,10 0 0,0 12,2Z" />
            </svg>
            <span>GitHub</span>
          </a>
        )}

      </div>
    </div>
  );
};

export default PluginLinks;