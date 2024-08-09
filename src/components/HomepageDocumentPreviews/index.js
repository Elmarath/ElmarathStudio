import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const DocumentList = [
  {
    title: "Advanced Hit Trailer (AHT)",
    Img: require('@site/static/img/T_AHT.png').default,
    description: (
      <>
        A modular, optimized solution for easily controlling and extending hit results from continuous hit trails.
      </>
    ),
    DocLink: '/docs/AdvancedHitTrailer',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: "Ability Queue System (AQS)",
    Img: require('@site/static/img/T_AbilityQueueSystemThumbnail.png').default,
    description: (
      <>
        Extension Of Gameplay Ability System from Epic. This system uses queue to activate abilities according to the priority of ability phase priorities. Allowing developers to create queueable abilities with ease.
      </>
    ),
    DocLink: '/docs/Ability-Queue-System/AbilityQueueSystem',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: "Nested Inventory Architecture (NIA)",
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: (
      <>
        Allow players to have intuitive and easy to use inventory systems! By allowing you to create customizable, nested, section based, object oriented architecture.
      </>
    ),
    DocLink: '/docs/Nested-Invnetory-Architecture/AboutNestedInventoryArchitecture',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/nested-inventory-architecture',
  },
  {
    title: "Modular Action System (MAS)",
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: (
      <>
        A solution for creating action systems. Data driven, modular, and easy to use and edit.
        Network ready, and can be used for any type of game uses animation.
      </>
    ),
    DocLink: '/docs/Modular-Action-System/About-Modular-Action-System',
    MarketplaceLink: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  }
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
  return (
    <section className={styles.documents}>
      <div className="container">
        <h1 style={{ textAlign: 'center' }}>Documents</h1>
        <div className={clsx('row', styles.centeredRow)}>
          {DocumentList.map((props, idx) => (
            <Document key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}