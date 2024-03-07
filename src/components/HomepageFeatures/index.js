import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Unreal Marketplace',
    Svg: require('@site/static/img/undraw_web_shopping_re_owap.svg').default,
    description: (
      <>
        Creating <a href="https://www.unrealengine.com/marketplace/en-US/profile/Elmarath?count=20&sortBy=effectiveDate&sortDir=DESC&start=0">Unreal Engine Marketplace</a> plug-ins with modularity in mind. For making games easier!
      </>
    ),
  },
  {
    title: "Hermod's Ride",
    Svg: require('@site/static/img/undraw_gaming_re_cma2 (1).svg').default,
    description: (
      <>
        A topdown arena medieval slasher game currently in development.
      </>
    ),
  },
  {
    title: 'Social',
    Svg: require('@site/static/img/undraw_community_re_cyrm.svg').default,
    description: (
      <>
        Check out our <a href="https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ">Youtube Channel</a>, <a href="https://twitter.com/denizhan_toprak">Twitter</a> to see what we have been doing!
        Also join our comminty with joining our <a href="https://discord.gg/HghXuWHJJx">Discord</a>!
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
