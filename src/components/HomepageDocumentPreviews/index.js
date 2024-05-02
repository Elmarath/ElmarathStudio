import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const DocumentList = [
  {
    title: <a href="/docs/category/nested-inventory-architecture-nia">Nested Inventory Architecture (NIA)</a>,
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: (
      <>
        Allow players to have intuitive and easy to use inventory systems! By allowing you to create customizable, nested, section based, object oriented architecture.
      </>
    ),
  },
  {
    title: <a href="/docs/category/modular-action-system">Modular Action System (MAS)</a>,
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: (
      <>
        A solution for creating action systems. Data driven, modular, and easy to use and edit.
        Network ready, and can be used for any type of game uses animation.
      </>
    ),
  }
];

function Document({ Img, title, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img src={Img} className={styles.documentImg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageDocumentPreviews() {
  return (
    <section className={styles.documents}>
      <div className="container">
        <div className={clsx('row', styles.centeredRow)}>
          {DocumentList.map((props, idx) => (
            <Document key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}