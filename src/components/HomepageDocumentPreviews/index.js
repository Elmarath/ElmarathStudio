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
];

function Document({ Img, title, DocLink, MarketplaceLink, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <a href={DocLink}>
          <img src={Img} className={styles.documentImg} alt={title} />
        </a>
      </div>
      <div className="text--center padding-horiz--md">
        <a href={DocLink}>
          <Heading as="h3">{title}</Heading>
        </a>
        <p>{description}</p>
        <p>
          <a href={MarketplaceLink}>Marketplace</a>
        </p>
      </div>
    </div>
  );
}

export default function HomepageDocumentPreviews() {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredDocuments = DocumentList.filter((doc) =>
    doc.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <section className={styles.documents}>
      <div className="container">
        <div className={styles.sectionHeader}>
          <a
            href="/docs/intro" /* Use a relative path */
            className={clsx(styles.sectionTitleLink, 'text--primary')}
          >
            Documentation
          </a>
          <input
            type="text"
            placeholder="Search documentation..."
            className={styles.searchBar}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className={clsx('row', styles.centeredRow)}>
          {filteredDocuments.map((props, idx) => (
            <Document key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}