import React from 'react';
import styles from './HeaderBox.module.css';

const HeaderBox = () => {
    const siteConfig = {
        title: "Elmarath Studio"
    };
    
    return (
        <div className={styles.headerBox}>
            <img
                src={require('@site/static/img/T_ElmarathLogo.png').default}
                alt="Elmarath Studio Logo"
                className={styles.logo}
            />
            <h1 className={styles.siteTitle}>{siteConfig.title}</h1>
            <p className={styles.description}>Game and Game Tools Development</p>
        </div>
    );
};

export default HeaderBox;
