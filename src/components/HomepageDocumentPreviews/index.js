import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const DocumentList = [
  {
    title: <a href="/docs/AdvancedHitTrailer">Advanved Hit Trailer (AHT)</a>,
    Img: require('@site/static/img/T_AHT.png').default,
    description: (
      <>
        A modular, optimized solution for easily controlling and extending hit results from continuous hit trails.
      </>
    ),
    link: 'https://www.unrealengine.com/marketplace/en-US/profile/Elmarath?count=20&sortBy=effectiveDate&sortDir=DESC&start=0',
  },
  {
    title: <a href="/docs/Ability-Queue-System/AbilityQueueSystem">Ability Queue System (AQS)</a>,
    Img: require('@site/static/img/T_AbilityQueueSystemThumbnail.png').default,
    description: (
      <>
        Extension Of Gameplay Ability System from Epic. This system uses queue to activate abilities accourding to the priority of ability phase priorities. Allowing developers to create queueable abilities with ease.
      </>
    ),
    link: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: <a href="/docs/Nested-Invnetory-Architecture/AboutNestedInventoryArchitecture">Nested Inventory Architecture (NIA)</a>,
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: (
      <>
        Allow players to have intuitive and easy to use inventory systems! By allowing you to create customizable, nested, section based, object oriented architecture.
      </>
    ),
    link: 'https://www.unrealengine.com/marketplace/en-US/product/nested-inventory-architecture',
  },
  {
    title: <a href="/docs/Modular-Action-System/About-Modular-Action-System">Modular Action System (MAS)</a>,
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: (
      <>
        A solution for creating action systems. Data driven, modular, and easy to use and edit.
        Network ready, and can be used for any type of game uses animation.
      </>
    ),
    link: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  }
];

function Document({ Img, title, link, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img src={Img} className={styles.documentImg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
        <p>
          <a href={link}>Marketplace</a>
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