import React, { useState } from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import { DOCUMENT_LIST } from '../../data';
import { useExternalLink, useSearch } from '../../hooks';
import styles from './styles.module.css';

function Document({ Img, title, DocLink, MarketplaceLink, GitHubLink, description }) {
  const openExternalLink = useExternalLink();
  const handleCardClick = (e) => {
    // Only navigate if the click wasn't on a button or link
    if (!e.target.closest('a') && !e.target.closest('button')) {
      window.location.href = DocLink;
    }
  };

  return (
    <div className={styles.documentCard}>
      <div className={styles.cardContainer} onClick={handleCardClick}>
        {/* Background Icon - Always visible at same size */}
        <div className={styles.backgroundIcon}>
          <img src={Img} className={styles.backgroundImg} alt={title} />
        </div>
        
        {/* Main content overlay */}
        <div className={styles.contentOverlay}>
          {/* Always visible header with title */}
          <div className={styles.cardHeader}>
            <a href={DocLink} className={styles.titleLink}>
              <Heading as="h3" className={styles.documentTitle}>{title}</Heading>
            </a>
          </div>
          
          {/* Expandable description section - only visible on hover */}
          <div className={styles.expandableContent}>
            <div className={styles.descriptionSection}>
              <p className={styles.documentDescription}>{description}</p>
            </div>
          </div>
          
          {/* Always visible action buttons */}
          <div className={styles.actionsSection}>
            <div className={styles.cardActions}>
              <a 
                href={DocLink} 
                className={styles.docsButton}
                onClick={(e) => e.stopPropagation()}
              >
                <svg className={styles.buttonIcon} viewBox="0 0 24 24" fill="currentColor">
                  <path d="M14,3V5H17.59L7.76,14.83L9.17,16.24L19,6.41V10H21V3M19,19H5V5H12V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V12H19V19Z"/>
                </svg>
                Docs
              </a>
              {MarketplaceLink && (
                <a 
                  href={MarketplaceLink} 
                  target="_blank" 
                  rel="noopener noreferrer" 
                  className={styles.marketplaceButton}
                  onClick={(e) => {
                    e.stopPropagation();
                    openExternalLink(MarketplaceLink);
                  }}
                >
                  <svg className={styles.buttonIcon} viewBox="0 0 24 24" fill="currentColor">
                    <path d="M6 4V20H9V14H15V11H9V7H16V4H6Z"/>
                  </svg>
                  Fab
                </a>
              )}
              {GitHubLink && (
                <a 
                  href={GitHubLink} 
                  target="_blank" 
                  rel="noopener noreferrer" 
                  className={styles.githubButton}
                  onClick={(e) => {
                    e.stopPropagation();
                    openExternalLink(GitHubLink);
                  }}
                >
                  <svg className={styles.buttonIcon} viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12,2A10,10 0 0,0 2,12C2,16.42 4.87,20.17 8.84,21.5C9.34,21.58 9.5,21.27 9.5,21C9.5,20.77 9.5,20.14 9.5,19.31C6.73,19.91 6.14,17.97 6.14,17.97C5.68,16.81 5.03,16.5 5.03,16.5C4.12,15.88 5.1,15.9 5.1,15.9C6.1,15.97 6.63,16.93 6.63,16.93C7.5,18.45 8.97,18 9.54,17.76C9.63,17.11 9.89,16.67 10.17,16.42C7.95,16.17 5.62,15.31 5.62,11.5C5.62,10.39 6,9.5 6.65,8.79C6.55,8.54 6.2,7.5 6.75,6.15C6.75,6.15 7.59,5.88 9.5,7.17C10.29,6.95 11.15,6.84 12,6.84C12.85,6.84 13.71,6.95 14.5,7.17C16.41,5.88 17.25,6.15 17.25,6.15C17.8,7.5 17.45,8.54 17.35,8.79C18,9.5 18.38,10.39 18.38,11.5C18.38,15.32 16.04,16.16 13.81,16.41C14.17,16.72 14.5,17.33 14.5,18.26C14.5,19.6 14.5,20.68 14.5,21C14.5,21.27 14.66,21.59 15.17,21.5C19.14,20.16 22,16.42 22,12A10,10 0 0,0 12,2Z"/>
                  </svg>
                  GitHub
                </a>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function HomepageDocumentPreviews() {
  const { searchTerm, setSearchTerm, filteredItems: filteredDocuments } = useSearch(
    DOCUMENT_LIST,
    ['title', 'description']
  );

  return (
    <section className={styles.documents}>
      <div className={styles.fullWidthContainer}>
        <div className={styles.sectionHeader}>
          <a
            href="/docs/intro"
            className={clsx(styles.sectionTitleLink, 'text--primary')}
          >
            Documentation
          </a>
          <p className={styles.sectionSubtitle}>
            Explore my Unreal Engine plugins and game development tools
          </p>
          
          <div className={styles.searchContainer}>
            <div className={styles.searchInputWrapper}>
              <svg className={styles.searchIcon} viewBox="0 0 24 24" fill="currentColor">
                <path d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"/>
              </svg>
              <input
                type="text"
                placeholder="Search plugins and documentation..."
                className={styles.searchBar}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              {searchTerm && (
                <button 
                  className={styles.clearButton}
                  onClick={() => setSearchTerm('')}
                  aria-label="Clear search"
                >
                  ×
                </button>
              )}
            </div>
            {searchTerm && (
              <div className={styles.searchResults}>
                {filteredDocuments.length} plugin{filteredDocuments.length !== 1 ? 's' : ''} found
              </div>
            )}
          </div>
        </div>
        
        <div className={styles.documentGrid}>
          {filteredDocuments.length > 0 ? (
            filteredDocuments.map((props, idx) => (
              <Document key={idx} {...props} />
            ))
          ) : (
            <div className={styles.noResults}>
              <svg className={styles.noResultsIcon} viewBox="0 0 24 24" fill="currentColor">
                <path d="M15.5,14L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5M9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14Z"/>
              </svg>
              <h3>No plugins found</h3>
              <p>Try adjusting your search terms</p>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}