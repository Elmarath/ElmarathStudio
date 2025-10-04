import React, { useState } from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const DocumentList = [
  {
    title: "Local Staged Interaction (LSI)",
    Img: require('@site/static/img/T_LSI_LocalStagedInteractionThumbanil.png').default,
    description: "Local Interaction System that uses stages as a way to create complex player interactions with ease.",
    DocLink: 'docs/Local-Staged-Interaction/AboutLocalStagedInteraction',
    MarketplaceLink: '',
  },
  {
    title: "Advanced Hit Trailer (AHT)",
    Img: require('@site/static/img/T_AHT.png').default,
    description: "A modular, optimized solution for easily controlling and extending hit results from continuous hit trails.",
    DocLink: '/docs/AdvancedHitTrailer',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: "Ability Queue System (AQS)",
    Img: require('@site/static/img/T_AbilityQueueSystemThumbnail.png').default,
    description: "Extension of Epic's Gameplay Ability System. Enables queueable abilities with priority-based activation.",
    DocLink: '/docs/Ability-Queue-System/AbilityQueueSystem',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: "Nested Inventory Architecture (NIA)",
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: "Create customizable, nested, section-based, object-oriented inventory systems for intuitive gameplay.",
    DocLink: '/docs/Nested-Invnetory-Architecture/AboutNestedInventoryArchitecture',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/nested-inventory-architecture',
  },
  {
    title: "Modular Action System (MAS)",
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: "A modular, data-driven action system for games. Network-ready and easy to customize.",
    DocLink: '/docs/Modular-Action-System/About-Modular-Action-System',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  },
  {
    title: "Easy Skeletal Mesh Merge Async",
    Img: require('@site/static/img/EasySkeletalMeshMergeAsync.png').default,
    description: "A simple and optimized workflow to create modular characters via skele merging.",
    DocLink: '/docs/Easy-Skeletal-Mesh-Merge-Async/EasySkeletalMeshMergeAsync',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  },
  {
    title: "Easy Ability Set System",
    Img: require('@site/static/img/T_EasyAbilitySetSystem_Logo.png').default,
    description: "Ability Set Management System that handles both granting and input binding for Gameplay Ability System.",
    DocLink: '/docs/Easy-Ability-Set-System/EasyAbilitySetSystemStartup',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  }
];

function Document({ Img, title, DocLink, MarketplaceLink, description }) {
  return (
    <div className={styles.documentCard}>
      <div className={styles.cardContainer}>
        <div className={styles.imageContainer}>
          <a href={DocLink} className={styles.imageLink}>
            <img src={Img} className={styles.documentImg} alt={title} />
            <div className={styles.imageOverlay}>
              <span className={styles.viewDocsButton}>View Documentation</span>
            </div>
          </a>
        </div>
        <div className={styles.cardContent}>
          <a href={DocLink} className={styles.titleLink}>
            <Heading as="h3" className={styles.documentTitle}>{title}</Heading>
          </a>
          <p className={styles.documentDescription}>{description}</p>
          <div className={styles.cardActions}>
            <a href={DocLink} className={styles.docsButton}>
              <svg className={styles.buttonIcon} viewBox="0 0 24 24" fill="currentColor">
                <path d="M14,3V5H17.59L7.76,14.83L9.17,16.24L19,6.41V10H21V3M19,19H5V5H12V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V12H19V19Z"/>
              </svg>
              Documentation
            </a>
            {MarketplaceLink && (
              <a href={MarketplaceLink} target="_blank" rel="noopener noreferrer" className={styles.marketplaceButton}>
                <svg className={styles.buttonIcon} viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12,2C13.1,2 14,2.9 14,4C14,5.1 13.1,6 12,6C10.9,6 10,5.1 10,4C10,2.9 10.9,2 12,2M21,9V7L15,1H5C3.89,1 3,1.89 3,3V7H9V9H21M4,8V21A1,1 0 0,0 5,22H19A1,1 0 0,0 20,21V8H4Z"/>
                </svg>
                Marketplace
              </a>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function HomepageDocumentPreviews() {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredDocuments = DocumentList.filter((doc) =>
    doc.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    doc.description.toLowerCase().includes(searchTerm.toLowerCase())
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