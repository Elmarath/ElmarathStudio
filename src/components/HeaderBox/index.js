import React from 'react';
import HeaderCard from '../HeaderCard';
import styles from './HeaderBox.module.css';
import pluginStyles from '../PluginLinks/PluginLinks.module.css';

const HeaderBox = () => {
    return (
                <HeaderCard>
                        <img 
                                src="/img/T_ElmarathLogo.png" 
                                alt="Elmarath Studio Logo" 
                                className={styles.logo} 
                        />
                        <h3 className={styles.siteTitle}>Elmarath Studio</h3>
                        <p className={styles.description}>Professional Game Development Tools</p>
                        <div className={styles.vendorLinks}>
                            <a
                                href="https://www.fab.com/sellers/Elmarath"
                                target="_blank"
                                rel="noopener noreferrer"
                                title="Elmarath on Fab"
                                className={`${pluginStyles.linkButton} ${pluginStyles.fabButton}`}
                                aria-label="Elmarath on Fab Vendor"
                            >
                                <img src="/img/T_Epic_Games_Fab_2024_icon.svg" alt="Fab Vendor" className={styles.vendorIcon} />
                                <span>Fab Vendor</span>
                            </a>
                        </div>
                </HeaderCard>
    );
};

export default HeaderBox;
